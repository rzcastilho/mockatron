  defmodule MockatronWeb.RequestConditionController do
  use MockatronWeb, :controller

  alias Mockatron.Core
  alias Mockatron.Core.RequestCondition

  action_fallback MockatronWeb.FallbackController

  def index(conn, %{"agent_id" => agent_id, "filter_id" => filter_id}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Core.get_agent_from_user(agent_id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})
      agent ->
        case Core.get_filter_from_agent(filter_id, agent) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Not Found"})
          filter ->
            request_conditions = Core.list_request_conditions_by_filter(filter)
            render(conn, "index.json", request_conditions: request_conditions)
        end
    end
  end

  def create(conn, %{"agent_id" => agent_id, "filter_id" => filter_id, "request_condition" => request_condition_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Core.get_agent_from_user(agent_id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})
      agent ->
        case Core.get_filter_from_agent(filter_id, agent) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Not Found"})
          filter ->
            with {:ok, %RequestCondition{} = request_condition} <- Core.create_request_condition(request_condition_params, filter) do
              conn
              |> put_status(:created)
              |> put_resp_header("location", agent_filter_request_condition_path(conn, :show, agent_id, filter_id, request_condition))
              |> render("show.json", request_condition: request_condition)
            end
        end
    end
  end

  def show(conn, %{"agent_id" => agent_id, "filter_id" => filter_id, "id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Core.get_agent_from_user(agent_id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})
      agent ->
        case Core.get_filter_from_agent(filter_id, agent) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Not Found"})
          filter ->
            case Core.get_request_condition_from_filter(id, filter) do
              nil ->
                conn
                |> put_status(:not_found)
                |> json(%{error: "Not Found"})
              request_condition ->
                render(conn, "show.json", request_condition: request_condition)
            end
        end
    end
  end

  def update(conn, %{"agent_id" => agent_id, "filter_id" => filter_id, "id" => id, "request_condition" => request_condition_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Core.get_agent_from_user(agent_id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})
      agent ->
        case Core.get_filter_from_agent(filter_id, agent) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Not Found"})
          filter ->
            case Core.get_request_condition_from_filter(id, filter) do
              nil ->
                conn
                |> put_status(:not_found)
                |> json(%{error: "Not Found"})
              request_condition ->
                with {:ok, %RequestCondition{} = request_condition} <- Core.update_request_condition(request_condition, request_condition_params) do
                  render(conn, "show.json", request_condition: request_condition)
                end
            end
        end
    end
  end

  def delete(conn, %{"agent_id" => agent_id, "filter_id" => filter_id, "id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Core.get_agent_from_user(agent_id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})
      agent ->
        case Core.get_filter_from_agent(filter_id, agent) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Not Found"})
          filter ->
            case Core.get_request_condition_from_filter(id, filter) do
              nil ->
                conn
                |> put_status(:not_found)
                |> json(%{error: "Not Found"})
              request_condition ->
                with {:ok, %RequestCondition{}} <- Core.delete_request_condition(request_condition) do
                  send_resp(conn, :no_content, "")
                end
            end
        end
    end
  end

end
