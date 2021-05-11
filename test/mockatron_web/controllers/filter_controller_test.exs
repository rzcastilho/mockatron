defmodule MockatronWeb.FilterControllerTest do
  use MockatronWeb.ConnCase

  import Ecto.Query

  alias Mockatron.Repo

  alias Mockatron.Core
  alias Mockatron.Core.Agent
  alias Mockatron.Core.Filter

  alias Mockatron.Guardian
  alias Mockatron.Auth

  @user_valid_attrs %{
    email: "test@mockatron.io",
    password: "Welcome1",
    password_confirmation: "Welcome1",
    verified: true
  }
  @agent_valid_attrs %{
    content_type: "application/json",
    host: "localhost",
    method: "GET",
    path: "/json",
    port: 4000,
    protocol: "http",
    responder: "RANDOM"
  }

  @create_attrs %{enable: true, label: "success", priority: 0}
  @update_attrs %{enable: false, label: "error", priority: 1}
  @invalid_attrs %{enable: nil, label: nil, priority: nil}

  def fixture(:filter) do
    agent =
      Repo.one(
        from a in Agent,
          select: a,
          where:
            a.content_type == "application/json" and a.host == "localhost" and a.method == "GET" and
              a.path == "/json" and a.port == 4000 and a.protocol == "http" and
              a.responder == "RANDOM"
      )

    {:ok, filter} = Core.create_filter(@create_attrs, agent)
    filter
  end

  setup %{conn: conn} do
    {:ok, user} = Auth.create_user(@user_valid_attrs)
    {:ok, agent} = Core.create_agent(@agent_valid_attrs, user)
    {:ok, token, _} = Guardian.encode_and_sign(user, %{}, token_type: :access)

    conn =
      conn
      |> put_req_header("accept", "application/json")
      |> put_req_header("authorization", "bearer " <> token)

    {:ok, conn: conn, agent: agent}
  end

  describe "index" do
    test "lists all filters", %{conn: conn, agent: agent} do
      conn = get(conn, Routes.agent_filter_path(conn, :index, agent))
      assert json_response(conn, 200)["data"] == []
    end

    test "agent not found", %{conn: conn} do
      conn = get(conn, Routes.agent_filter_path(conn, :index, %Agent{id: 1000}))
      assert response(conn, 404)
    end
  end

  describe "show" do
    setup [:create_filter]

    test "chosen filter", %{conn: conn, agent: agent, filter: %Filter{id: id}} do
      conn = get(conn, Routes.agent_filter_path(conn, :show, agent, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "enable" => true,
               "label" => "success",
               "priority" => 0
             }
    end

    test "filter not found", %{conn: conn, agent: agent} do
      conn = get(conn, Routes.agent_filter_path(conn, :show, agent, 1000))
      assert response(conn, 404)
    end

    test "agent not found", %{conn: conn, filter: %Filter{id: id}} do
      conn = get(conn, Routes.agent_filter_path(conn, :show, %Agent{id: 1000}, id))
      assert response(conn, 404)
    end
  end

  describe "create filter" do
    test "renders filter when data is valid", %{conn: conn, agent: agent} do
      conn1 = post conn, Routes.agent_filter_path(conn, :create, agent), filter: @create_attrs
      assert %{"id" => id} = json_response(conn1, 201)["data"]

      conn2 = get(conn, Routes.agent_filter_path(conn, :show, agent, id))

      assert json_response(conn2, 200)["data"] == %{
               "id" => id,
               "enable" => true,
               "label" => "success",
               "priority" => 0
             }
    end

    test "renders errors when data is invalid", %{conn: conn, agent: agent} do
      conn = post conn, Routes.agent_filter_path(conn, :create, agent), filter: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "agent not found", %{conn: conn} do
      conn =
        post conn, Routes.agent_filter_path(conn, :create, %Agent{id: 1000}),
          filter: @create_attrs

      assert response(conn, 404)
    end
  end

  describe "update filter" do
    setup [:create_filter]

    test "renders filter when data is valid", %{
      conn: conn,
      agent: agent,
      filter: %Filter{id: id} = filter
    } do
      conn1 =
        put conn, Routes.agent_filter_path(conn, :update, agent, filter), filter: @update_attrs

      assert %{"id" => ^id} = json_response(conn1, 200)["data"]

      conn2 = get(conn, Routes.agent_filter_path(conn, :show, agent, id))

      assert json_response(conn2, 200)["data"] == %{
               "id" => id,
               "enable" => false,
               "label" => "error",
               "priority" => 1
             }
    end

    test "renders errors when data is invalid", %{conn: conn, agent: agent, filter: filter} do
      conn =
        put conn, Routes.agent_filter_path(conn, :update, agent, filter), filter: @invalid_attrs

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "filter not found", %{conn: conn, agent: agent} do
      conn =
        put conn, Routes.agent_filter_path(conn, :update, agent, %Filter{id: 1000}),
          filter: @create_attrs

      assert response(conn, 404)
    end

    test "agent not found", %{conn: conn, filter: filter} do
      conn =
        put conn, Routes.agent_filter_path(conn, :update, %Agent{id: 1000}, filter),
          filter: @create_attrs

      assert response(conn, 404)
    end
  end

  describe "delete filter" do
    setup [:create_filter]

    test "deletes chosen filter", %{conn: conn, agent: agent, filter: filter} do
      conn = delete(conn, Routes.agent_filter_path(conn, :delete, agent, filter))
      assert response(conn, 204)
      conn = get(conn, Routes.agent_filter_path(conn, :show, agent, filter))
      assert response(conn, 404)
    end

    test "filter not found", %{conn: conn, agent: agent} do
      conn = delete(conn, Routes.agent_filter_path(conn, :delete, agent, %Filter{id: 1000}))
      assert response(conn, 404)
    end

    test "agent not found", %{conn: conn, filter: filter} do
      conn = delete(conn, Routes.agent_filter_path(conn, :delete, %Agent{id: 1000}, filter))
      assert response(conn, 404)
    end
  end

  defp create_filter(_) do
    filter = fixture(:filter)
    %{filter: filter}
  end
end
