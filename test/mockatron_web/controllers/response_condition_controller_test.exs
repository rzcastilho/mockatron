defmodule MockatronWeb.ResponseConditionControllerTest do
  use MockatronWeb.ConnCase

  import Ecto.Query

  alias Mockatron.Repo

  alias Mockatron.Core
  alias Mockatron.Core.Filter
  alias Mockatron.Core.ResponseCondition

  alias Mockatron.Guardian
  alias Mockatron.Auth

  @user_valid_attrs %{email: "test@mockatron.io", password: "Welcome1", password_confirmation: "Welcome1", verified: true}
  @agent_valid_attrs %{content_type: "application/json", host: "localhost", method: "GET", path: "/json", port: 4000, protocol: "http", responder: "RANDOM"}
  @filter_valid_attrs %{enable: true, label: "success", priority: 0}

  @create_attrs %{field_type: "LABEL", operator: "STARTSWITH", value: "Success"}
  @update_attrs %{field_type: "HTTP_CODE", operator: "EQUALS", value: "200"}
  @invalid_attrs %{field_type: nil, operator: nil, value: nil}

  def fixture(:response_condition) do
    filter = Repo.one(from a in Filter, select: a, where: a.label == "success" and a.priority == 0 and a.enable == true)
    {:ok, response_condition} = Core.create_response_condition(@create_attrs, filter)
    response_condition
  end

  setup %{conn: conn} do
    {:ok, user} = Auth.create_user(@user_valid_attrs)
    {:ok, agent} = Core.create_agent(@agent_valid_attrs, user)
    {:ok, filter} = Core.create_filter(@filter_valid_attrs, agent)
    {:ok, token, _} = Guardian.encode_and_sign(user, %{}, token_type: :access)
    conn = conn
           |> put_req_header("accept", "application/json")
           |> put_req_header("authorization", "bearer " <> token)
    {:ok, conn: conn, filter: filter}
  end

  describe "index" do

    test "lists all response_conditions", %{conn: conn, filter: filter} do
      conn = get conn, agent_filter_response_condition_path(conn, :index, filter.agent_id, filter)
      assert json_response(conn, 200)["data"] == []
    end

    test "agent not found", %{conn: conn, filter: filter} do
      conn = get conn, agent_filter_response_condition_path(conn, :index, 1000, filter)
      assert response(conn, 404)
    end

    test "filter not found", %{conn: conn, filter: filter} do
      conn = get conn, agent_filter_response_condition_path(conn, :index, filter.agent_id, %Filter{id: 1000})
      assert response(conn, 404)
    end

  end

  describe "show" do
    setup [:create_response_condition]

    test "chosen response condition", %{conn: conn, filter: filter, response_condition: %ResponseCondition{id: id}} do
      conn = get conn, agent_filter_response_condition_path(conn, :show, filter.agent_id, filter, id)
      assert json_response(conn, 200)["data"] == %{
               "id" => id,
               "field_type" => "LABEL",
               "operator" => "STARTSWITH",
               "value" => "Success"
             }
    end

    test "response condition not found", %{conn: conn, filter: filter} do
      conn = get conn, agent_filter_response_condition_path(conn, :show, filter.agent_id, filter, 1000)
      assert response(conn, 404)
    end

    test "filter not found", %{conn: conn, filter: filter, response_condition: %ResponseCondition{id: id}} do
      conn = get conn, agent_filter_response_condition_path(conn, :show, filter.agent_id, %Filter{id: 1000}, id)
      assert response(conn, 404)
    end

    test "agent not found", %{conn: conn, filter: filter, response_condition: %ResponseCondition{id: id}} do
      conn = get conn, agent_filter_response_condition_path(conn, :show, 1000, filter, id)
      assert response(conn, 404)
    end

  end

  describe "create response_condition" do
    
    test "renders response_condition when data is valid", %{conn: conn, filter: filter} do
      conn1 = post conn, agent_filter_response_condition_path(conn, :create, filter.agent_id, filter), response_condition: @create_attrs
      assert %{"id" => id} = json_response(conn1, 201)["data"]

      conn2 = get conn, agent_filter_response_condition_path(conn, :show, filter.agent_id, filter, id)
      assert json_response(conn2, 200)["data"] == %{
        "id" => id,
        "field_type" => "LABEL",
        "operator" => "STARTSWITH",
        "value" => "Success"}
    end

    test "renders errors when data is invalid", %{conn: conn, filter: filter} do
      conn = post conn, agent_filter_response_condition_path(conn, :create, filter.agent_id, filter), response_condition: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "filter not found", %{conn: conn, filter: filter} do
      conn = post conn, agent_filter_response_condition_path(conn, :create, filter.agent_id, %Filter{id: 1000}), response_condition: @create_attrs
      assert response(conn, 404)
    end

    test "agent not found", %{conn: conn, filter: filter} do
      conn = post conn, agent_filter_response_condition_path(conn, :create, 1000, filter), response_condition: @create_attrs
      assert response(conn, 404)
    end
  
  end

  describe "update response_condition" do
    setup [:create_response_condition]

    test "renders response_condition when data is valid", %{conn: conn, filter: filter, response_condition: %ResponseCondition{id: id} = response_condition} do
      conn1 = put conn, agent_filter_response_condition_path(conn, :update, filter.agent_id, filter, response_condition), response_condition: @update_attrs
      assert %{"id" => ^id} = json_response(conn1, 200)["data"]

      conn2 = get conn, agent_filter_response_condition_path(conn, :show, filter.agent_id, filter, id)
      assert json_response(conn2, 200)["data"] == %{
        "id" => id,
        "field_type" => "HTTP_CODE",
        "operator" => "EQUALS",
        "value" => "200"}
    end

    test "renders errors when data is invalid", %{conn: conn, filter: filter, response_condition: response_condition} do
      conn = put conn, agent_filter_response_condition_path(conn, :update, filter.agent_id, filter, response_condition), response_condition: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "response condition not found", %{conn: conn, filter: filter} do
      conn = put conn, agent_filter_response_condition_path(conn, :update, filter.agent_id, filter, %ResponseCondition{id: 1000}), response_condition: @create_attrs
      assert response(conn, 404)
    end

    test "filter not found", %{conn: conn, filter: filter, response_condition: response_condition} do
      conn = put conn, agent_filter_response_condition_path(conn, :update, filter.agent_id, %Filter{id: 1000}, response_condition), response_condition: @create_attrs
      assert response(conn, 404)
    end

    test "agent not found", %{conn: conn, filter: filter, response_condition: response_condition} do
      conn = put conn, agent_filter_response_condition_path(conn, :update, 1000, filter, response_condition), response_condition: @create_attrs
      assert response(conn, 404)
    end
  end

  describe "delete response_condition" do
    setup [:create_response_condition]

    test "deletes chosen response_condition", %{conn: conn, filter: filter, response_condition: response_condition} do
      conn1 = delete conn, agent_filter_response_condition_path(conn, :delete, filter.agent_id, filter, response_condition)
      assert response(conn1, 204)
      conn2 = get conn, agent_filter_response_condition_path(conn, :show, filter.agent_id, filter, response_condition)
      assert response(conn2, 404)
    end

    test "response condition not found", %{conn: conn, filter: filter} do
      conn = delete conn, agent_filter_response_condition_path(conn, :delete, filter.agent_id, filter, %ResponseCondition{id: 1000})
      assert response(conn, 404)
    end

    test "filter not found", %{conn: conn, filter: filter, response_condition: response_condition} do
      conn = delete conn, agent_filter_response_condition_path(conn, :delete, filter.agent_id, %Filter{id: 1000}, response_condition)
      assert response(conn, 404)
    end

    test "agent not found", %{conn: conn, filter: filter, response_condition: response_condition} do
      conn = delete conn, agent_filter_response_condition_path(conn, :delete, 1000, filter, response_condition)
      assert response(conn, 404)
    end
  
  end

  defp create_response_condition(_) do
    response_condition = fixture(:response_condition)
    {:ok, response_condition: response_condition}
  end
end
