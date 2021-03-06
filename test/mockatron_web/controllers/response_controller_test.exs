defmodule MockatronWeb.ResponseControllerTest do
  use MockatronWeb.ConnCase

  alias Mockatron.Core
  alias Mockatron.Core.Response

  import Ecto.Query

  alias Mockatron.Repo

  alias Mockatron.Core
  alias Mockatron.Core.Agent
  alias Mockatron.Core.Response

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

  @create_attrs %{
    body: "{\n  \"code\":0,\n  \"message\":\"Success\"\n}",
    enable: true,
    http_code: 200,
    label: "success"
  }
  @update_attrs %{
    body:
      "<mockatron>\n  <code>404</code>\n  <message>Not Found</message>\n  <description>No agent found to meet this request</description>\n</mockatron>",
    enable: false,
    http_code: 404,
    label: "error"
  }
  @invalid_attrs %{body: nil, enable: nil, http_code: nil, label: nil}

  def fixture(:response) do
    agent =
      Repo.one(
        from a in Agent,
          select: a,
          where:
            a.content_type == "application/json" and a.host == "localhost" and a.method == "GET" and
              a.path == "/json" and a.port == 4000 and a.protocol == "http" and
              a.responder == "RANDOM"
      )

    {:ok, response} = Core.create_response(@create_attrs, agent)
    response
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
    test "lists all responses", %{conn: conn, agent: agent} do
      conn = get(conn, Routes.agent_response_path(conn, :index, agent))
      assert json_response(conn, 200)["data"] == []
    end

    test "agent not found", %{conn: conn} do
      conn = get(conn, Routes.agent_response_path(conn, :index, %Agent{id: 1000}))
      assert response(conn, 404)
    end
  end

  describe "show" do
    setup [:create_response]

    test "chosen response", %{conn: conn, agent: agent, response: %Response{id: id}} do
      conn = get(conn, Routes.agent_response_path(conn, :show, agent, id))

      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "body" => "{\n  \"code\":0,\n  \"message\":\"Success\"\n}",
               "enable" => true,
               "http_code" => 200,
               "label" => "success"
             }
    end

    test "response not found", %{conn: conn, agent: agent} do
      conn = get(conn, Routes.agent_response_path(conn, :show, agent, 1000))
      assert response(conn, 404)
    end

    test "agent not found", %{conn: conn, response: %Response{id: id}} do
      conn = get(conn, Routes.agent_response_path(conn, :show, %Agent{id: 1000}, id))
      assert response(conn, 404)
    end
  end

  describe "create response" do
    test "renders response when data is valid", %{conn: conn, agent: agent} do
      conn1 = post conn, Routes.agent_response_path(conn, :create, agent), response: @create_attrs
      assert %{"id" => id} = json_response(conn1, 201)["data"]

      conn2 = get(conn, Routes.agent_response_path(conn, :show, agent, id))

      assert json_response(conn2, 200)["data"] == %{
               "id" => id,
               "body" => "{\n  \"code\":0,\n  \"message\":\"Success\"\n}",
               "enable" => true,
               "http_code" => 200,
               "label" => "success"
             }
    end

    test "renders errors when data is invalid", %{conn: conn, agent: agent} do
      conn = post conn, Routes.agent_response_path(conn, :create, agent), response: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "agent not found", %{conn: conn} do
      conn =
        post conn, Routes.agent_response_path(conn, :create, %Agent{id: 1000}),
          response: @create_attrs

      assert response(conn, 404)
    end
  end

  describe "update response" do
    setup [:create_response]

    test "renders response when data is valid", %{
      conn: conn,
      agent: agent,
      response: %Response{id: id} = response
    } do
      conn1 =
        put conn, Routes.agent_response_path(conn, :update, agent, response),
          response: @update_attrs

      assert %{"id" => ^id} = json_response(conn1, 200)["data"]

      conn2 = get(conn, Routes.agent_response_path(conn, :show, agent, id))

      assert json_response(conn2, 200)["data"] == %{
               "id" => id,
               "body" =>
                 "<mockatron>\n  <code>404</code>\n  <message>Not Found</message>\n  <description>No agent found to meet this request</description>\n</mockatron>",
               "enable" => false,
               "http_code" => 404,
               "label" => "error"
             }
    end

    test "renders errors when data is invalid", %{conn: conn, agent: agent, response: response} do
      conn =
        put conn, Routes.agent_response_path(conn, :update, agent, response),
          response: @invalid_attrs

      assert json_response(conn, 422)["errors"] != %{}
    end

    test "response not found", %{conn: conn, agent: agent} do
      conn =
        put conn, Routes.agent_response_path(conn, :update, agent, %Response{id: 1000}),
          response: @create_attrs

      assert response(conn, 404)
    end

    test "agent not found", %{conn: conn, response: response} do
      conn =
        put conn, Routes.agent_response_path(conn, :update, %Agent{id: 1000}, response),
          response: @create_attrs

      assert response(conn, 404)
    end
  end

  describe "delete response" do
    setup [:create_response]

    test "deletes chosen response", %{conn: conn, agent: agent, response: response} do
      conn1 = delete(conn, Routes.agent_response_path(conn, :delete, agent, response))
      assert response(conn1, 204)
      conn2 = get(conn, Routes.agent_response_path(conn, :show, agent, response))
      assert response(conn2, 404)
    end

    test "response not found", %{conn: conn, agent: agent} do
      conn = delete(conn, Routes.agent_response_path(conn, :delete, agent, %Response{id: 1000}))
      assert response(conn, 404)
    end

    test "agent not found", %{conn: conn, response: response} do
      conn = delete(conn, Routes.agent_response_path(conn, :delete, %Agent{id: 1000}, response))
      assert response(conn, 404)
    end
  end

  defp create_response(_) do
    response = fixture(:response)
    %{response: response}
  end
end
