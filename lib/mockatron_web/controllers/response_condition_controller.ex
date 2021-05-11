defmodule MockatronWeb.ResponseConditionController do
  use MockatronWeb, :controller

  alias Mockatron.Core
  alias Mockatron.Core.ResponseCondition

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
            response_conditions = Core.list_response_conditions_by_filter(filter)
            render(conn, "index.json", response_conditions: response_conditions)
        end
    end
  end

  def create(conn, %{
        "agent_id" => agent_id,
        "filter_id" => filter_id,
        "response_condition" => response_condition_params
      }) do
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
            with {:ok, %ResponseCondition{} = response_condition} <-
                   Core.create_response_condition(response_condition_params, filter) do
              conn
              |> put_status(:created)
              |> put_resp_header(
                "location",
                Routes.agent_filter_response_condition_path(
                  conn,
                  :show,
                  agent_id,
                  filter_id,
                  response_condition
                )
              )
              |> render("show.json", response_condition: response_condition)
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
            case Core.get_response_condition_from_filter(id, filter) do
              nil ->
                conn
                |> put_status(:not_found)
                |> json(%{error: "Not Found"})

              response_condition ->
                render(conn, "show.json", response_condition: response_condition)
            end
        end
    end
  end

  def update(conn, %{
        "agent_id" => agent_id,
        "filter_id" => filter_id,
        "id" => id,
        "response_condition" => response_condition_params
      }) do
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
            case Core.get_response_condition_from_filter(id, filter) do
              nil ->
                conn
                |> put_status(:not_found)
                |> json(%{error: "Not Found"})

              response_condition ->
                with {:ok, %ResponseCondition{} = response_condition} <-
                       Core.update_response_condition(
                         response_condition,
                         response_condition_params
                       ) do
                  render(conn, "show.json", response_condition: response_condition)
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
            case Core.get_response_condition_from_filter(id, filter) do
              nil ->
                conn
                |> put_status(:not_found)
                |> json(%{error: "Not Found"})

              response_condition ->
                with {:ok, %ResponseCondition{}} <-
                       Core.delete_response_condition(response_condition) do
                  send_resp(conn, :no_content, "")
                end
            end
        end
    end
  end
end
