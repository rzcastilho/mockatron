defmodule MockatronWeb.FilterController do
  use MockatronWeb, :controller

  alias Mockatron.Core
  alias Mockatron.Core.Filter

  action_fallback MockatronWeb.FallbackController

  def index(conn, %{"agent_id" => agent_id}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Core.get_agent_from_user(agent_id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})
      agent ->
        filters = Core.list_filters_by_agent(agent)
        render(conn, "index.json", filters: filters)
    end
  end

  def create(conn, %{"agent_id" => agent_id, "filter" => filter_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Core.get_agent_from_user(agent_id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})
      agent ->
        with {:ok, %Filter{} = filter} <- Core.create_filter(filter_params, agent) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", Routes.agent_filter_path(conn, :show, agent_id, filter))
          |> render("show.json", filter: filter)
        end
    end
  end

  def show(conn, %{"agent_id" => agent_id, "id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Core.get_agent_from_user(agent_id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})
      agent ->
        case Core.get_filter_from_agent(id, agent) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Not Found"})
          filter ->
            render(conn, "show.json", filter: filter)
        end
    end
  end

  def update(conn, %{"agent_id" => agent_id, "id" => id, "filter" => filter_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Core.get_agent_from_user(agent_id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})
      agent ->
        case Core.get_filter_from_agent(id, agent) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Not Found"})
          filter ->
            with {:ok, %Filter{} = filter} <- Core.update_filter(filter, filter_params) do
              render(conn, "show.json", filter: filter)
            end
        end
    end
  end

  def delete(conn, %{"agent_id" => agent_id, "id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Core.get_agent_from_user(agent_id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})
      agent ->
        case Core.get_filter_from_agent(id, agent) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Not Found"})
          filter ->
            with {:ok, %Filter{}} <- Core.delete_filter(filter) do
              send_resp(conn, :no_content, "")
            end
        end
    end
  end

end
