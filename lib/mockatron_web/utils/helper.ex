defmodule MockatronWeb.Utils.Helper do
  import Ecto.Query
  import Plug.Conn
  alias Mockatron.AgentResponder.Signature
  alias Mockatron.Core.Agent
  alias Mockatron.Core.Filter
  alias Mockatron.Core.Response

  @not_found_xml "<mockatron>\n  <code>404</code>\n  <message>Not Found</message>\n  <description>No agent found to meet this request</description>\n</mockatron>"
  @not_found_json "{\n  \"code\":404,\n  \"message\":\"Not Found\",\n  \"description\":\"No agent found to meet this request\"\n}"
  @not_found_text "code: 404\nmessage: Not Found\ndescription: No agent found to meet this request"

  def agent_stringify(%Signature{} = signature) do
    case { signature.content_type, signature.operation } do
      { :none, :none }  ->
        "[User ID: #{signature.user_id}] #{signature.method} #{signature.protocol}://#{signature.host}:#{signature.port}#{signature.path}"
      { _, :none } ->
        "[User ID: #{signature.user_id}] #{signature.method} #{signature.protocol}://#{signature.host}:#{signature.port}#{signature.path} [Content Type: #{signature.content_type}]"
      { :none, _ } ->
        "[User ID: #{signature.user_id}] #{signature.method} #{signature.protocol}://#{signature.host}:#{signature.port}#{signature.path} [Operation: #{signature.operation}]"
      _ ->
        "[User ID: #{signature.user_id}] #{signature.method} #{signature.protocol}://#{signature.host}:#{signature.port}#{signature.path} [Content Type: #{signature.content_type}] [Operation: #{signature.operation}]"
    end
  end

  def agent_stringify(%Signature{} = signature, %Filter{} = filter) do
    agent_stringify(signature) <> "[Filter ID: #{filter.id}]"
  end

  def agent_hash(%Signature{} = signature) do
    :crypto.hash(:md5, agent_stringify(signature)) |> Base.encode16(case: :lower)
  end

  def agent_hash(%Signature{} = signature, %Filter{} = filter) do
    :crypto.hash(:md5, agent_stringify(signature, filter)) |> Base.encode16(case: :lower)
  end

  def assert(source, operator, target)  do
    case operator do
      "EQUALS" ->
        source == target
      "NOTEQUALS" ->
        source != target
      "CONTAINS" ->
        String.contains?(source, target)
      "STARTSWITH" ->
        String.starts_with?(source, target)
      "ENDSWITH" ->
        String.ends_with?(source, target)
      "REGEX" ->
        Regex.match?(Regex.compile!(target), source)
    end
  end

  def load_agent(repo, %Signature{} = signature) do
    case { signature.content_type, signature.operation } do
      { :none, :none }  ->
        repo.one(from a in Agent, select: a, where: ^signature.user_id == a.user_id and ^signature.method == a.method and ^signature.protocol == a.protocol and ^signature.host == a.host and ^signature.port == a.port and ^signature.path == a.path)
      { _, :none } ->
        repo.one(from a in Agent, select: a, where: ^signature.user_id == a.user_id and ^signature.method == a.method and ^signature.protocol == a.protocol and ^signature.host == a.host and ^signature.port == a.port and ^signature.path == a.path and ^signature.content_type == a.content_type)
      { :none, _ } ->
        repo.one(from a in Agent, select: a, where: ^signature.user_id == a.user_id and ^signature.method == a.method and ^signature.protocol == a.protocol and ^signature.host == a.host and ^signature.port == a.port and ^signature.path == a.path and ^signature.operation == a.operation)
      _ ->
        repo.one(from a in Agent, select: a, where: ^signature.user_id == a.user_id and ^signature.method == a.method and ^signature.protocol == a.protocol and ^signature.host == a.host and ^signature.port == a.port and ^signature.path == a.path and ^signature.content_type == a.content_type and ^signature.operation == a.operation)
    end
    |> Mockatron.Repo.preload([responses: from(r in Response, where: r.enable == true)])
    |> Mockatron.Repo.preload([filters: {from(f in Filter, where: f.enable == true, order_by: f.priority), [:request_conditions, :response_conditions]}])
  end

  def filter_responses(%Agent{} = agent, %Filter{} = filter) do
    filtered_responses = Enum.filter(agent.responses, fn response -> assert_response_conditions(response, filter.response_conditions) end)
    Map.put(agent, :responses, filtered_responses)
  end

  def assert_response_conditions(%{label: label} = response, [%{field_type: "LABEL", operator: operator, value: value}|conditions]) do
    case assert(label, operator, value) do
      true ->
        assert_response_conditions(response, conditions)
      _ ->
        false
    end
  end

  def assert_response_conditions(%{http_code: http_code} = response, [%{field_type: "HTTP_CODE", operator: operator, value: value}|conditions]) do
    case assert(Integer.to_string(http_code), operator, value) do
      true ->
        assert_response_conditions(response, conditions)
      _ ->
        false
    end
  end

  def assert_response_conditions(%{body: body} = response, [%{field_type: "BODY", operator: operator, value: value}|conditions]) do
    case assert(body, operator, value) do
      true ->
        assert_response_conditions(response, conditions)
      _ ->
        false
    end
  end

  def assert_response_conditions(_, []) do
    true
  end

  def send_agent_not_found_resp(%Plug.Conn{assigns: %{mockatron: %{signature: %{content_type: "application/json" = content_type}}}} = conn) do
    conn
    |> put_resp_content_type(content_type)
    |> put_status(:not_found)
    |> send_resp(404, @not_found_json)
  end

  def send_agent_not_found_resp(%Plug.Conn{assigns: %{mockatron: %{signature: %{content_type: "text/xml" = content_type}}}} = conn) do
    conn
    |> put_resp_content_type(content_type)
    |> put_status(:not_found)
    |> send_resp(404, @not_found_xml)
  end

  def send_agent_not_found_resp(%Plug.Conn{assigns: %{mockatron: %{signature: %{content_type: "application/soap+xml" = content_type}}}} = conn) do
    conn
    |> put_resp_content_type(content_type)
    |> put_status(:not_found)
    |> send_resp(404, @not_found_xml)
  end

  def send_agent_not_found_resp(%Plug.Conn{assigns: %{mockatron: %{signature: %{content_type: _content_type}}}} = conn) do
    conn
    |> put_resp_content_type("text/plain")
    |> put_status(:not_found)
    |> send_resp(404, @not_found_text)
  end

end
