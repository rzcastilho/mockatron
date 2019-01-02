defmodule MockatronWeb.RequestConditionControllerTest do
  use MockatronWeb.ConnCase

  import Ecto.Query

  alias Mockatron.Repo

  alias Mockatron.Core
  alias Mockatron.Core.Filter
  alias Mockatron.Core.RequestCondition

  alias Mockatron.Guardian
  alias Mockatron.Auth

  @user_valid_attrs %{email: "test@mockatron.io", password: "Welcome1", password_confirmation: "Welcome1", verified: true}
  @agent_valid_attrs %{content_type: "application/json", host: "localhost", method: "GET", path: "/json", port: 4000, protocol: "http", responder: "RANDOM"}
  @filter_valid_attrs %{enable: true, label: "success", priority: 0}

  @create_attrs %{field_type: "BODY", header_or_query_param: nil, operator: "REGEX", value: "OK"}
  @update_attrs %{field_type: "QUERY_PARAM", header_or_query_param: "status", operator: "EQUALS", value: "success"}
  @invalid_attrs %{field_type: nil, header_or_query_param: nil, operator: nil, value: nil}

  def fixture(:request_condition) do
    filter = Repo.one(from a in Filter, select: a, where: a.label == "success" and a.priority == 0 and a.enable == true)
    {:ok, request_condition} = Core.create_request_condition(@create_attrs, filter)
    request_condition
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
    test "lists all request_conditions", %{conn: conn, filter: filter} do
      conn = get conn, agent_filter_request_condition_path(conn, :index, filter.agent_id, filter)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create request_condition" do
    test "renders request_condition when data is valid", %{conn: conn, filter: filter} do
      conn1 = post conn, agent_filter_request_condition_path(conn, :create, filter.agent_id, filter), request_condition: @create_attrs
      assert %{"id" => id} = json_response(conn1, 201)["data"]

      conn2 = get conn, agent_filter_request_condition_path(conn, :show, filter.agent_id, filter, id)
      assert json_response(conn2, 200)["data"] == %{
        "id" => id,
        "field_type" => "BODY",
        "header_or_query_param" => nil,
        "operator" => "REGEX",
        "value" => "OK"}
    end

    test "renders errors when data is invalid", %{conn: conn, filter: filter} do
      conn = post conn, agent_filter_request_condition_path(conn, :create, filter.agent_id, filter), request_condition: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update request_condition" do
    setup [:create_request_condition]

    test "renders request_condition when data is valid", %{conn: conn, filter: filter, request_condition: %RequestCondition{id: id} = request_condition} do
      conn1 = put conn, agent_filter_request_condition_path(conn, :update, filter.agent_id, filter, request_condition), request_condition: @update_attrs
      assert %{"id" => ^id} = json_response(conn1, 200)["data"]

      conn2 = get conn, agent_filter_request_condition_path(conn, :show, filter.agent_id, filter, id)
      assert json_response(conn2, 200)["data"] == %{
        "id" => id,
        "field_type" => "QUERY_PARAM",
        "header_or_query_param" => "status",
        "operator" => "EQUALS",
        "value" => "success"}
    end

    test "renders errors when data is invalid", %{conn: conn, filter: filter, request_condition: request_condition} do
      conn = put conn, agent_filter_request_condition_path(conn, :update, filter.agent_id, filter, request_condition), request_condition: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete request_condition" do
    setup [:create_request_condition]

    test "deletes chosen request_condition", %{conn: conn, filter: filter, request_condition: request_condition} do
      conn1 = delete conn, agent_filter_request_condition_path(conn, :delete, filter.agent_id, filter, request_condition)
      assert response(conn1, 204)
      conn2 = get conn, agent_filter_request_condition_path(conn, :show, filter.agent_id, filter, request_condition)
      assert response(conn2, 404)
    end
  end

  defp create_request_condition(_) do
    request_condition = fixture(:request_condition)
    {:ok, request_condition: request_condition}
  end
end
