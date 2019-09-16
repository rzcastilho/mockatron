defmodule MockatronWeb.ResponseController do
  use MockatronWeb, :controller

  alias Mockatron.Core
  alias Mockatron.Core.Response

  action_fallback MockatronWeb.FallbackController

  def index(conn, %{"agent_id" => agent_id}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Core.get_agent_from_user(agent_id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})
      agent ->
        responses = Core.list_responses_by_agent(agent)
        render(conn, "index.json", responses: responses)
    end
  end

  def create(conn, %{"agent_id" => agent_id, "response" => response_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Core.get_agent_from_user(agent_id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})
      agent ->
        with {:ok, %Response{} = response} <- Core.create_response(response_params, agent) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", Routes.agent_response_path(conn, :show, agent_id, response))
          |> render("show.json", response: response)
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
        case Core.get_response_from_agent(id, agent) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Not Found"})
          response ->
            render(conn, "show.json", response: response)
        end
    end
  end

  def update(conn, %{"agent_id" => agent_id, "id" => id, "response" => response_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    case Core.get_agent_from_user(agent_id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})
      agent ->
        case Core.get_response_from_agent(id, agent) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Not Found"})
          response ->
            with {:ok, %Response{} = response} <- Core.update_response(response, response_params) do
              render(conn, "show.json", response: response)
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
        case Core.get_response_from_agent(id, agent) do
          nil ->
            conn
            |> put_status(:not_found)
            |> json(%{error: "Not Found"})
          response ->
            with {:ok, %Response{}} <- Core.delete_response(response) do
              send_resp(conn, :no_content, "")
            end
        end
    end
  end

end
