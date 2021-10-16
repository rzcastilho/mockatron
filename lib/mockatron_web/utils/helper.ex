defmodule MockatronWeb.Utils.Helper do
  import Ecto.Query
  import Plug.Conn
  alias Mockatron.AgentResponder.Signature
  alias Mockatron.Core.Agent
  alias Mockatron.Core.Filter
  alias Mockatron.Core.Response
  
  @error_mock_templates "lib/mockatron_web/templates/error/mock"

  def agent_stringify(%Signature{} = signature) do
    case {signature.content_type, signature.operation} do
      {:none, :none} ->
        "[User ID: #{signature.user_id}] #{signature.method} #{signature.protocol}://#{
          signature.host
        }:#{signature.port}#{signature.path}"

      {_, :none} ->
        "[User ID: #{signature.user_id}] #{signature.method} #{signature.protocol}://#{
          signature.host
        }:#{signature.port}#{signature.path} [Content Type: #{signature.content_type}]"

      {:none, _} ->
        "[User ID: #{signature.user_id}] #{signature.method} #{signature.protocol}://#{
          signature.host
        }:#{signature.port}#{signature.path} [Operation: #{signature.operation}]"

      _ ->
        "[User ID: #{signature.user_id}] #{signature.method} #{signature.protocol}://#{
          signature.host
        }:#{signature.port}#{signature.path} [Content Type: #{signature.content_type}] [Operation: #{
          signature.operation
        }]"
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

  def assert(source, operator, target) do
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

  def filter_signature_params({:__struct__, _}), do: false
  def filter_signature_params({_, :none}), do: false
  def filter_signature_params(_), do: true

  def load_agent(%Signature{} = signature, repo) do
    signature
    |> Map.to_list()
    |> Enum.filter(&filter_signature_params/1)
    |> load_agent(repo)
    |> repo.preload(responses: from(r in Response, where: r.enable == true))
    |> repo.preload(
      filters:
        {from(f in Filter, where: f.enable == true, order_by: f.priority),
         [:request_conditions, :response_conditions]}
    )
  end

  def load_agent(filters, repo) when is_list(filters) do
    case repo.one(from a in Agent, select: a, where: ^filters) do
      %Agent{} = agent ->
        agent

      _ ->
        filters
        |> List.keydelete(:path, 0)
        |> load_agent(filters |> List.keyfind(:path, 0) |> elem(1), repo)
    end
  end

  def load_agent(filters, path, repo) when is_list(filters) and is_bitstring(path) do
    path
    |> String.split("/")
    |> Enum.filter(&(&1 != ""))
    |> Enum.reverse()
    |> load_agent(path, filters, repo)
  end

  def load_agent([_ | rest], original_path, filters, repo) do
    conditions =
      build_dynamic_conditions(filters, "/#{rest |> Enum.reverse() |> Enum.join("/")}%")

    case repo.all(from a in Agent, select: a, where: ^conditions) do
      nil ->
        load_agent(rest, original_path, filters, repo)

      agents ->
        Enum.reduce_while(agents, nil, fn agent, _acc ->
          reduce_agents_by_regex(original_path, agent)
        end)
    end
  end

  def load_agent([], _original_path, _filters, _repo), do: nil

  def reduce_agents_by_regex(original_path, %Agent{path_regex: path_regex} = agent) do
    with {:ok, regex} <- Regex.compile(path_regex) do
      case Regex.match?(regex, original_path) do
        true -> {:halt, agent}
        _ -> {:cont, nil}
      end
    end
  end

  def build_dynamic_conditions(filters, path) do
    conditions = dynamic([a], like(a.path, ^path) and not is_nil(a.path_regex))

    conditions =
      case List.keyfind(filters, :user_id, 0) do
        {:user_id, user_id} -> dynamic([a], a.user_id == ^user_id and ^conditions)
        _ -> conditions
      end

    conditions =
      case List.keyfind(filters, :method, 0) do
        {:method, method} -> dynamic([a], a.method == ^method and ^conditions)
        _ -> conditions
      end

    conditions =
      case List.keyfind(filters, :protocol, 0) do
        {:protocol, protocol} -> dynamic([a], a.protocol == ^protocol and ^conditions)
        _ -> conditions
      end

    conditions =
      case List.keyfind(filters, :host, 0) do
        {:host, host} -> dynamic([a], a.host == ^host and ^conditions)
        _ -> conditions
      end

    conditions =
      case List.keyfind(filters, :port, 0) do
        {:port, port} -> dynamic([a], a.port == ^port and ^conditions)
        _ -> conditions
      end

    conditions =
      case List.keyfind(filters, :operation, 0) do
        {:operation, operation} -> dynamic([a], a.operation == ^operation and ^conditions)
        _ -> conditions
      end

    conditions =
      case List.keyfind(filters, :content_type, 0) do
        {:content_type, content_type} ->
          dynamic([a], a.content_type == ^content_type and ^conditions)

        _ ->
          conditions
      end

    conditions
  end

  def filter_responses(%Agent{} = agent, %Filter{} = filter) do
    filtered_responses =
      Enum.filter(agent.responses, fn response ->
        assert_response_conditions(response, filter.response_conditions)
      end)

    Map.put(agent, :responses, filtered_responses)
  end

  def assert_response_conditions(%{label: label} = response, [
        %{field_type: "LABEL", operator: operator, value: value} | conditions
      ]) do
    case assert(label, operator, value) do
      true ->
        assert_response_conditions(response, conditions)

      _ ->
        false
    end
  end

  def assert_response_conditions(%{http_code: http_code} = response, [
        %{field_type: "HTTP_CODE", operator: operator, value: value} | conditions
      ]) do
    case assert(Integer.to_string(http_code), operator, value) do
      true ->
        assert_response_conditions(response, conditions)

      _ ->
        false
    end
  end

  def assert_response_conditions(%{body: body} = response, [
        %{field_type: "BODY", operator: operator, value: value} | conditions
      ]) do
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

  def send_agent_not_found_resp(
        %Plug.Conn{
          assigns: %{mockatron: %{signature: %{content_type: "application/json" = content_type}}}
        } = conn
      ) do
    conn
    |> put_resp_content_type(content_type)
    |> put_status(:not_found)
    |> send_resp(404, EEx.eval_file(Path.join([@error_mock_templates, "json.eex"]), assigns: [code: 404, message: "Not Found", description: "No agent found to meet this request"], trim: true))
  end

  def send_agent_not_found_resp(
        %Plug.Conn{
          assigns: %{mockatron: %{signature: %{content_type: content_type}}}
        } = conn
      ) when content_type in ["text/xml", "application/soap+xml"] do
    conn
    |> put_resp_content_type(content_type)
    |> put_status(:not_found)
    |> send_resp(404, EEx.eval_file(Path.join([@error_mock_templates, "xml.eex"]), assigns: [code: 404, message: "Not Found", description: "No agent found to meet this request"], trim: true))
  end

  def send_agent_not_found_resp(
        %Plug.Conn{assigns: %{mockatron: %{signature: %{content_type: _content_type}}}} = conn
      ) do
    conn
    |> put_resp_content_type("text/plain")
    |> put_status(:not_found)
    |> send_resp(404, EEx.eval_file(Path.join([@error_mock_templates, "plain.eex"]), assigns: [code: 404, message: "Not Found", description: "No agent found to meet this request"], trim: true))
  end
  
  def send_error_processing_template_resp(
        %Plug.Conn{
          assigns: %{mockatron: %{signature: %{content_type: "application/json" = content_type}}}
        } = conn, error, detail
      ) do
    conn
    |> put_resp_content_type(content_type)
    |> put_status(:not_found)
    |> send_resp(500, EEx.eval_file(Path.join([@error_mock_templates, "json.eex"]), assigns: [code: 500, message: "Internal Server Error", description: "Error processing response template", error: error, detail: detail], trim: true))
  end

  def send_error_processing_template_resp(
        %Plug.Conn{
          assigns: %{mockatron: %{signature: %{content_type: content_type}}}
        } = conn, error, detail
      ) when content_type in ["text/xml", "application/soap+xml"] do
    conn
    |> put_resp_content_type(content_type)
    |> put_status(:not_found)
    |> send_resp(500, EEx.eval_file(Path.join([@error_mock_templates, "xml.eex"]), assigns: [code: 500, message: "Internal Server Error", description: "Error processing response template", error: error, detail: detail], trim: true))
  end

  def send_error_processing_template_resp(
        %Plug.Conn{assigns: %{mockatron: %{signature: %{content_type: _content_type}}}} = conn, error, detail
      ) do
    conn
    |> put_resp_content_type("text/plain")
    |> put_status(:not_found)
    |> send_resp(500, EEx.eval_file(Path.join([@error_mock_templates, "plain.eex"]), assigns: [code: 500, message: "Internal Server Error", description: "Error processing response template", error: error, detail: detail], trim: true))
  end
  
end
