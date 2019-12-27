defmodule Mockatron.CoreTest do
  use Mockatron.DataCase

  alias Mockatron.Core

  @user_valid_attrs %{email: "test@mockatron.io", password: "Welcome1", password_confirmation: "Welcome1", verified: true}
  @agent_valid_attrs %{content_type: "application/json", host: "localhost", method: "GET", path: "/json", port: 4000, protocol: "http", responder: "RANDOM"}
  @filter_valid_attrs %{enable: true, label: "success", priority: 0}

  describe "agents" do
    alias Mockatron.Core.Agent

    @valid_attrs @agent_valid_attrs
    @update_attrs %{content_type: "text/xml", host: "localhost", method: "POST", path: "/xml", port: 8080, protocol: "https", responder: "SEQUENTIAL", operation: "do"}
    @update_path_param_attrs %{content_type: "application/json", host: "localhost", method: "GET", path: "/json/<id>", port: 4000, protocol: "http", responder: "RANDOM", operation: nil}
    @update_path_param_custom_regex_attrs %{content_type: "application/json", host: "localhost", method: "GET", path: "/json/<id:[0-9]+>", port: 4000, protocol: "http", responder: "RANDOM", operation: nil}
    @invalid_attrs %{content_type: nil, host: nil, method: nil, path: nil, port: nil, protocol: nil, responder: nil}

    setup do
      {:ok, user} = Mockatron.Auth.create_user(@user_valid_attrs)
      {:ok, user: user}
    end

    def agent_fixture(user, attrs \\ %{}) do
      {:ok, agent} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_agent(user)

      agent
    end

    test "list_agents/0 returns all agents", %{user: user} do
      agent = agent_fixture(user)
      assert Core.list_agents() == [agent]
    end

    test "get_agent!/1 returns the agent with given id", %{user: user} do
      agent = agent_fixture(user)
      assert Core.get_agent!(agent.id) == agent
    end

    test "create_agent/1 with valid data creates a agent", %{user: user} do
      assert {:ok, %Agent{} = agent} = Core.create_agent(@valid_attrs, user)
      assert agent.content_type == "application/json"
      assert agent.host == "localhost"
      assert agent.method == "GET"
      assert agent.path == "/json"
      assert agent.path_regex == nil
      assert agent.port == 4000
      assert agent.protocol == "http"
      assert agent.responder == "RANDOM"
      assert agent.operation == nil
    end

    test "create_agent/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Core.create_agent(@invalid_attrs, user)
    end

    test "update_agent/2 with valid data updates the agent", %{user: user} do
      agent = agent_fixture(user)
      assert {:ok, agent} = Core.update_agent(agent, @update_attrs)
      assert %Agent{} = agent
      assert agent.content_type == "text/xml"
      assert agent.host == "localhost"
      assert agent.method == "POST"
      assert agent.path == "/xml"
      assert agent.path_regex == nil
      assert agent.port == 8080
      assert agent.protocol == "https"
      assert agent.responder == "SEQUENTIAL"
      assert agent.operation == "do"
    end

    test "update_agent/2 with valid data and path param updates the agent and generates path_regex attr", %{user: user} do
      agent = agent_fixture(user)
      assert {:ok, agent} = Core.update_agent(agent, @update_path_param_attrs)
      assert %Agent{} = agent
      assert agent.content_type == "application/json"
      assert agent.host == "localhost"
      assert agent.method == "GET"
      assert agent.path == "/json/<id>"
      assert agent.path_regex == "^/json/(?<id>[^/]+)$"
      assert agent.port == 4000
      assert agent.protocol == "http"
      assert agent.responder == "RANDOM"
      assert agent.operation == nil
    end

    test "update_agent/2 with valid data and path param with custom regex updates the agent and generates path_regex attr", %{user: user} do
      agent = agent_fixture(user)
      assert {:ok, agent} = Core.update_agent(agent, @update_path_param_custom_regex_attrs)
      assert %Agent{} = agent
      assert agent.content_type == "application/json"
      assert agent.host == "localhost"
      assert agent.method == "GET"
      assert agent.path == "/json/<id:[0-9]+>"
      assert agent.path_regex == "^/json/(?<id>[0-9]+)$"
      assert agent.port == 4000
      assert agent.protocol == "http"
      assert agent.responder == "RANDOM"
      assert agent.operation == nil
    end

    test "update_agent/2 with invalid data returns error changeset", %{user: user} do
      agent = agent_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Core.update_agent(agent, @invalid_attrs)
      assert agent == Core.get_agent!(agent.id)
    end

    test "delete_agent/1 deletes the agent", %{user: user} do
      agent = agent_fixture(user)
      assert {:ok, %Agent{}} = Core.delete_agent(agent)
      assert_raise Ecto.NoResultsError, fn -> Core.get_agent!(agent.id) end
    end

    test "change_agent/1 returns a agent changeset", %{user: user} do
      agent = agent_fixture(user)
      assert %Ecto.Changeset{} = Core.change_agent(agent)
    end
  end

  describe "responses" do
    alias Mockatron.Core.Response

    @valid_attrs %{body: "{\n  \"code\":0,\n  \"message\":\"Success\"\n}", enable: true, http_code: 200, label: "success"}
    @update_attrs %{body: "<mockatron>\n  <code>404</code>\n  <message>Not Found</message>\n  <description>No agent found to meet this request</description>\n</mockatron>", enable: false, http_code: 404, label: "error"}
    @invalid_attrs %{body: nil, enable: nil, http_code: nil, label: nil}

    setup do
      {:ok, user} = Mockatron.Auth.create_user(@user_valid_attrs)
      {:ok, agent} = Core.create_agent(@agent_valid_attrs, user)
      {:ok, agent: agent}
    end

    def response_fixture(agent, attrs \\ %{}) do
      {:ok, response} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_response(agent)

      response
    end

    test "list_responses/0 returns all responses", %{agent: agent} do
      response = response_fixture(agent)
      assert Core.list_responses() == [response]
    end

    test "get_response!/1 returns the response with given id", %{agent: agent} do
      response = response_fixture(agent)
      assert Core.get_response!(response.id) == response
    end

    test "create_response/1 with valid data creates a response", %{agent: agent} do
      assert {:ok, %Response{} = response} = Core.create_response(@valid_attrs, agent)
      assert response.body == "{\n  \"code\":0,\n  \"message\":\"Success\"\n}"
      assert response.enable == true
      assert response.http_code == 200
      assert response.label == "success"
    end

    test "create_response/1 with invalid data returns error changeset", %{agent: agent} do
      assert {:error, %Ecto.Changeset{}} = Core.create_response(@invalid_attrs, agent)
    end

    test "update_response/2 with valid data updates the response", %{agent: agent} do
      response = response_fixture(agent)
      assert {:ok, response} = Core.update_response(response, @update_attrs)
      assert %Response{} = response
      assert response.body == "<mockatron>\n  <code>404</code>\n  <message>Not Found</message>\n  <description>No agent found to meet this request</description>\n</mockatron>"
      assert response.enable == false
      assert response.http_code == 404
      assert response.label == "error"
    end

    test "update_response/2 with invalid data returns error changeset", %{agent: agent} do
      response = response_fixture(agent)
      assert {:error, %Ecto.Changeset{}} = Core.update_response(response, @invalid_attrs)
      assert response == Core.get_response!(response.id)
    end

    test "delete_response/1 deletes the response", %{agent: agent} do
      response = response_fixture(agent)
      assert {:ok, %Response{}} = Core.delete_response(response)
      assert_raise Ecto.NoResultsError, fn -> Core.get_response!(response.id) end
    end

    test "change_response/1 returns a response changeset", %{agent: agent} do
      response = response_fixture(agent)
      assert %Ecto.Changeset{} = Core.change_response(response)
    end
  end

  describe "filters" do
    alias Mockatron.Core.Filter

    @valid_attrs @filter_valid_attrs
    @update_attrs %{enable: false, label: "error", priority: 1}
    @invalid_attrs %{enable: nil, label: nil, priority: nil}

    setup do
      {:ok, user} = Mockatron.Auth.create_user(@user_valid_attrs)
      {:ok, agent} = Core.create_agent(@agent_valid_attrs, user)
      {:ok, agent: agent}
    end

    def filter_fixture(agent, attrs \\ %{}) do
      {:ok, filter} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_filter(agent)

      filter
    end

    test "list_filters/0 returns all filters", %{agent: agent} do
      filter = filter_fixture(agent)
      assert Core.list_filters() == [filter]
    end

    test "get_filter!/1 returns the filter with given id", %{agent: agent} do
      filter = filter_fixture(agent)
      assert Core.get_filter!(filter.id) == filter
    end

    test "create_filter/1 with valid data creates a filter", %{agent: agent} do
      assert {:ok, %Filter{} = filter} = Core.create_filter(@valid_attrs, agent)
      assert filter.enable == true
      assert filter.label == "success"
      assert filter.priority == 0
    end

    test "create_filter/1 with invalid data returns error changeset", %{agent: agent} do
      assert {:error, %Ecto.Changeset{}} = Core.create_filter(@invalid_attrs, agent)
    end

    test "update_filter/2 with valid data updates the filter", %{agent: agent} do
      filter = filter_fixture(agent)
      assert {:ok, filter} = Core.update_filter(filter, @update_attrs)
      assert %Filter{} = filter
      assert filter.enable == false
      assert filter.label == "error"
      assert filter.priority == 1
    end

    test "update_filter/2 with invalid data returns error changeset", %{agent: agent} do
      filter = filter_fixture(agent)
      assert {:error, %Ecto.Changeset{}} = Core.update_filter(filter, @invalid_attrs)
      assert filter == Core.get_filter!(filter.id)
    end

    test "delete_filter/1 deletes the filter", %{agent: agent} do
      filter = filter_fixture(agent)
      assert {:ok, %Filter{}} = Core.delete_filter(filter)
      assert_raise Ecto.NoResultsError, fn -> Core.get_filter!(filter.id) end
    end

    test "change_filter/1 returns a filter changeset", %{agent: agent} do
      filter = filter_fixture(agent)
      assert %Ecto.Changeset{} = Core.change_filter(filter)
    end
  end

  describe "request_conditions" do
    alias Mockatron.Core.RequestCondition

    @valid_attrs %{field_type: "BODY", param_name: nil, operator: "REGEX", value: "OK"}
    @update_attrs %{field_type: "QUERY_PARAM", param_name: "status", operator: "EQUALS", value: "success"}
    @invalid_attrs %{field_type: nil, param_name: nil, operator: nil, value: nil}

    setup do
      {:ok, user} = Mockatron.Auth.create_user(@user_valid_attrs)
      {:ok, agent} = Core.create_agent(@agent_valid_attrs, user)
      {:ok, filter} = Core.create_filter(@filter_valid_attrs, agent)
      {:ok, filter: filter}
    end

    def request_condition_fixture(filter, attrs \\ %{}) do
      {:ok, request_condition} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_request_condition(filter)

      request_condition
    end

    test "list_request_conditions/0 returns all request_conditions", %{filter: filter} do
      request_condition = request_condition_fixture(filter)
      assert Core.list_request_conditions() == [request_condition]
    end

    test "get_request_condition!/1 returns the request_condition with given id", %{filter: filter} do
      request_condition = request_condition_fixture(filter)
      assert Core.get_request_condition!(request_condition.id) == request_condition
    end

    test "create_request_condition/1 with valid data creates a request_condition", %{filter: filter} do
      assert {:ok, %RequestCondition{} = request_condition} = Core.create_request_condition(@valid_attrs, filter)
      assert request_condition.field_type == "BODY"
      assert request_condition.param_name == nil
      assert request_condition.operator == "REGEX"
      assert request_condition.value == "OK"
    end

    test "create_request_condition/1 with invalid data returns error changeset", %{filter: filter} do
      assert {:error, %Ecto.Changeset{}} = Core.create_request_condition(@invalid_attrs, filter)
    end

    test "update_request_condition/2 with valid data updates the request_condition", %{filter: filter} do
      request_condition = request_condition_fixture(filter)
      assert {:ok, request_condition} = Core.update_request_condition(request_condition, @update_attrs)
      assert %RequestCondition{} = request_condition
      assert request_condition.field_type == "QUERY_PARAM"
      assert request_condition.param_name == "status"
      assert request_condition.operator == "EQUALS"
      assert request_condition.value == "success"
    end

    test "update_request_condition/2 with invalid data returns error changeset", %{filter: filter} do
      request_condition = request_condition_fixture(filter)
      assert {:error, %Ecto.Changeset{}} = Core.update_request_condition(request_condition, @invalid_attrs)
      assert request_condition == Core.get_request_condition!(request_condition.id)
    end

    test "delete_request_condition/1 deletes the request_condition", %{filter: filter} do
      request_condition = request_condition_fixture(filter)
      assert {:ok, %RequestCondition{}} = Core.delete_request_condition(request_condition)
      assert_raise Ecto.NoResultsError, fn -> Core.get_request_condition!(request_condition.id) end
    end

    test "change_request_condition/1 returns a request_condition changeset", %{filter: filter} do
      request_condition = request_condition_fixture(filter)
      assert %Ecto.Changeset{} = Core.change_request_condition(request_condition)
    end
  end

  describe "response_conditions" do
    alias Mockatron.Core.ResponseCondition

    @valid_attrs %{field_type: "LABEL", operator: "STARTSWITH", value: "Success"}
    @update_attrs %{field_type: "HTTP_CODE", operator: "EQUALS", value: "200"}
    @invalid_attrs %{field_type: nil, operator: nil, value: nil}

    setup do
      {:ok, user} = Mockatron.Auth.create_user(@user_valid_attrs)
      {:ok, agent} = Core.create_agent(@agent_valid_attrs, user)
      {:ok, filter} = Core.create_filter(@filter_valid_attrs, agent)
      {:ok, filter: filter}
    end

    def response_condition_fixture(filter, attrs \\ %{}) do
      {:ok, response_condition} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Core.create_response_condition(filter)

      response_condition
    end

    test "list_response_conditions/0 returns all response_conditions", %{filter: filter} do
      response_condition = response_condition_fixture(filter)
      assert Core.list_response_conditions() == [response_condition]
    end

    test "get_response_condition!/1 returns the response_condition with given id", %{filter: filter} do
      response_condition = response_condition_fixture(filter)
      assert Core.get_response_condition!(response_condition.id) == response_condition
    end

    test "create_response_condition/1 with valid data creates a response_condition", %{filter: filter} do
      assert {:ok, %ResponseCondition{} = response_condition} = Core.create_response_condition(@valid_attrs, filter)
      assert response_condition.field_type == "LABEL"
      assert response_condition.operator == "STARTSWITH"
      assert response_condition.value == "Success"
    end

    test "create_response_condition/1 with invalid data returns error changeset", %{filter: filter} do
      assert {:error, %Ecto.Changeset{}} = Core.create_response_condition(@invalid_attrs, filter)
    end

    test "update_response_condition/2 with valid data updates the response_condition", %{filter: filter} do
      response_condition = response_condition_fixture(filter)
      assert {:ok, response_condition} = Core.update_response_condition(response_condition, @update_attrs)
      assert %ResponseCondition{} = response_condition
      assert response_condition.field_type == "HTTP_CODE"
      assert response_condition.operator == "EQUALS"
      assert response_condition.value == "200"
    end

    test "update_response_condition/2 with invalid data returns error changeset", %{filter: filter} do
      response_condition = response_condition_fixture(filter)
      assert {:error, %Ecto.Changeset{}} = Core.update_response_condition(response_condition, @invalid_attrs)
      assert response_condition == Core.get_response_condition!(response_condition.id)
    end

    test "delete_response_condition/1 deletes the response_condition", %{filter: filter} do
      response_condition = response_condition_fixture(filter)
      assert {:ok, %ResponseCondition{}} = Core.delete_response_condition(response_condition)
      assert_raise Ecto.NoResultsError, fn -> Core.get_response_condition!(response_condition.id) end
    end

    test "change_response_condition/1 returns a response_condition changeset", %{filter: filter} do
      response_condition = response_condition_fixture(filter)
      assert %Ecto.Changeset{} = Core.change_response_condition(response_condition)
    end
  end
end
