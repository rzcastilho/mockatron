defmodule MockatronWeb.AgentControllerTest do
  use MockatronWeb.ConnCase

  alias Mockatron.Core
  alias Mockatron.Core.Agent

  alias Mockatron.Guardian
  alias Mockatron.Auth

  @user_valid_attrs %{email: "test@mockatron.io", password: "Welcome1", password_confirmation: "Welcome1", verified: true}

  @create_attrs %{content_type: "application/json", host: "localhost", method: "GET", path: "/json", port: 4000, protocol: "http", responder: "RANDOM"}
  @update_attrs %{content_type: "text/xml", host: "localhost", method: "POST", path: "/xml", port: 8080, protocol: "https", responder: "SEQUENTIAL", operation: "do"}
  @invalid_attrs %{content_type: nil, host: nil, method: nil, path: nil, port: nil, protocol: nil, responder: nil}

  def fixture(:agent) do
    {:ok, user} = Auth.get_by_email(@user_valid_attrs.email)
    {:ok, agent} = Core.create_agent(@create_attrs, user)
    agent
  end

  setup %{conn: conn} do
    {:ok, user} = Auth.create_user(@user_valid_attrs)
    {:ok, token, _} = Guardian.encode_and_sign(user, %{}, token_type: :access)
    conn = conn
    |> put_req_header("accept", "application/json")
    |> put_req_header("authorization", "bearer " <> token)
    {:ok, conn: conn}
  end

  describe "index" do
    test "lists all agents", %{conn: conn} do
      conn = get conn, agent_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create agent" do
    test "renders agent when data is valid", %{conn: conn} do
      conn1 = post conn, agent_path(conn, :create), agent: @create_attrs
      assert %{"id" => id} = json_response(conn1, 201)["data"]

      conn2 = get conn, agent_path(conn, :show, id)
      assert json_response(conn2, 200)["data"] == %{
        "id" => id,
        "content_type" => "application/json",
        "host" => "localhost",
        "method" => "GET",
        "path" => "/json",
        "port" => 4000,
        "protocol" => "http",
        "responder" => "RANDOM",
        "operation" => nil}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, agent_path(conn, :create), agent: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update agent" do
    setup [:create_agent]

    test "renders agent when data is valid", %{conn: conn, agent: %Agent{id: id} = agent} do
      conn1 = put conn, agent_path(conn, :update, agent), agent: @update_attrs
      assert %{"id" => ^id} = json_response(conn1, 200)["data"]

      conn2 = get conn, agent_path(conn, :show, id)
      assert json_response(conn2, 200)["data"] == %{
        "id" => id,
        "content_type" => "text/xml",
        "host" => "localhost",
        "method" => "POST",
        "path" => "/xml",
        "port" => 8080,
        "protocol" => "https",
        "responder" => "SEQUENTIAL",
        "operation" => "do"}
    end

    test "renders errors when data is invalid", %{conn: conn, agent: agent} do
      conn = put conn, agent_path(conn, :update, agent), agent: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete agent" do
    setup [:create_agent]

    test "deletes chosen agent", %{conn: conn, agent: agent} do
      conn1 = delete conn, agent_path(conn, :delete, agent)
      assert response(conn1, 204)
      conn2 = get conn, agent_path(conn, :show, agent)
      assert response(conn2, 404)
    end
  end

  defp create_agent(_) do
    agent = fixture(:agent)
    {:ok, agent: agent}
  end
end
