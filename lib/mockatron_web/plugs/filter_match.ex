defmodule MockatronWeb.FilterMatch do
  import Plug.Conn
  alias MockatronWeb.Utils.Helper

  def init([]), do: []

  def call(%Plug.Conn{assigns: %{mockatron: %{agent: %{found: false}}}} = conn, _) do
    conn
  end

  def call(%Plug.Conn{assigns: %{mockatron: %{responder: responder, agent: %{found: true, hash: hash, agent: %{filters: []}}} = mockatron}} = conn, _) do
    conn
    |> assign(:mockatron, Map.merge(mockatron, %{responder: %{responder|hash: hash}}))
  end

  def call(%Plug.Conn{assigns: %{mockatron: %{signature: signature, responder: responder, agent: %{found: true, hash: hash, agent: %{filters: _} = agent}} = mockatron}} = conn, _) do
    case evaluate_filter(conn, agent) do
      {:ok, filter} ->
        conn
        |> assign(:mockatron, Map.merge(mockatron, %{responder: %{responder|hash: Helper.agent_hash(signature, filter), filter: filter}}))
      {:nomatch} ->
        conn
        |> assign(:mockatron, Map.merge(mockatron, %{responder: %{responder|hash: hash <> "[NOMATCH]"}}))
    end
  end

  defp evaluate_filter(conn, %{filters: filters}) do
    do_evaluate_filter(conn, filters)
  end

  defp do_evaluate_filter(_, []), do: { :nomatch }

  defp do_evaluate_filter(conn, [filter|filters]) do
    case evaluate_request_condition(conn, filter) do
      true ->
        { :ok, filter }
      _ ->
        do_evaluate_filter(conn, filters)
    end
  end

  def evaluate_request_condition(conn, %{request_conditions: request_conditions}) do
    do_evaluate_request_condition(conn, request_conditions)
  end

  defp do_evaluate_request_condition(_, []), do: true

  defp do_evaluate_request_condition(%{query_params: query_params} = conn, [%{field_type: "QUERY_PARAM", header_or_query_param: query_param, operator: operator, value: value} = _|request_conditions]) do
    case query_params do
      %{^query_param => param_value} ->
        case Helper.assert(param_value, operator, value) do
          true ->
            do_evaluate_request_condition(conn, request_conditions)
          _ ->
            false
        end
      _ ->
        false
    end

  end

  defp do_evaluate_request_condition(%{req_headers: req_headers} = conn, [%{field_type: "HEADER", header_or_query_param: header, operator: operator, value: value} = _|request_conditions]) do
    case req_headers do
      %{^header => header_value} ->
        case Helper.assert(header_value, operator, value) do
          true ->
            do_evaluate_request_condition(conn, request_conditions)
          _ ->
            false
        end
      _ ->
        false
    end
  end

  defp do_evaluate_request_condition(%{assigns: %{raw_body: [raw_body]}} = conn, [%{field_type: "BODY", operator: operator, value: value} = _|request_conditions]) do
    case Helper.assert(raw_body, operator, value) do
      true ->
        do_evaluate_request_condition(conn, request_conditions)
      _ ->
        false
    end
  end

end
