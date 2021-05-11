defmodule MockatronWeb.AgentController do
  use MockatronWeb, :controller

  alias Mockatron.Core
  alias Mockatron.Core.Agent

  action_fallback MockatronWeb.FallbackController

  def index(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    agents = Core.list_agents_by_user(current_user)
    render(conn, "index.json", agents: agents)
  end

  def create(conn, %{"agent" => agent_params}) do
    current_user = Guardian.Plug.current_resource(conn)

    with {:ok, %Agent{} = agent} <- Core.create_agent(agent_params, current_user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.agent_path(conn, :show, agent))
      |> render("show.json", agent: agent)
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    case Core.get_agent_from_user(id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})

      agent ->
        render(conn, "show.json", agent: agent)
    end
  end

  def update(conn, %{"id" => id, "agent" => agent_params}) do
    current_user = Guardian.Plug.current_resource(conn)

    case Core.get_agent_from_user(id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})

      agent ->
        with {:ok, %Agent{} = agent} <- Core.update_agent(agent, agent_params) do
          render(conn, "show.json", agent: agent)
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    case Core.get_agent_from_user(id, current_user) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not Found"})

      agent ->
        with {:ok, %Agent{}} <- Core.delete_agent(agent) do
          send_resp(conn, :no_content, "")
        end
    end
  end
end
