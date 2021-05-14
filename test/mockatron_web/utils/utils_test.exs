defmodule MockatronWeb.UtilsTest do
  use MockatronWeb.ConnCase, async: true

  alias MockatronWeb.Utils.Helper
  alias Mockatron.AgentResponder.Signature
  alias Mockatron.Core.Filter

  alias Mockatron.Guardian
  alias Mockatron.Auth

  @user_valid_attrs %{
    email: "test@mockatron.io",
    password: "Welcome1",
    password_confirmation: "Welcome1",
    verified: true
  }

  @signature %Signature{
    user_id: 1,
    method: "GET",
    protocol: "http",
    host: "mockatron.io",
    port: 80,
    path: "/do"
  }

  @filter %Filter{
    id: 1
  }

  @hash_signature "24a2c0c99a6778645aea52272002f81c"

  @hash_signature_filter "fb23be944a41cd489ec3411529809fce"

  @agent %Mockatron.Core.Agent{
    content_type: "application/json",
    host: "localhost",
    id: 3,
    inserted_at: ~N[2018-12-18 00:30:13.378925],
    method: "GET",
    path: "/sequential/filter",
    port: 4000,
    protocol: "http",
    responder: "SEQUENTIAL",
    responses: [
      %Mockatron.Core.Response{
        agent_id: 3,
        body: "{\"code\":\"99\",\"description\":\"Error\"}",
        enable: true,
        http_code: 400,
        id: 11,
        inserted_at: ~N[2018-12-18 00:33:53.113132],
        label: "Error",
        updated_at: ~N[2018-12-18 00:33:53.113143]
      },
      %Mockatron.Core.Response{
        agent_id: 3,
        body: "{\"code\":\"0\",\"description\":\"Success\"}",
        enable: true,
        http_code: 200,
        id: 3,
        inserted_at: ~N[2018-12-18 00:31:27.953022],
        label: "Success",
        updated_at: ~N[2018-12-18 00:31:27.953033]
      }
    ],
    updated_at: ~N[2018-12-18 00:30:13.378933]
  }

  @filter_label_success %Mockatron.Core.Filter{
    agent_id: 3,
    enable: true,
    id: 1,
    inserted_at: ~N[2018-12-18 00:35:23.424666],
    label: "Success",
    priority: 0,
    response_conditions: [
      %Mockatron.Core.ResponseCondition{
        field_type: "LABEL",
        filter_id: 1,
        id: 1,
        inserted_at: ~N[2018-12-18 00:42:17.289054],
        operator: "EQUALS",
        updated_at: ~N[2018-12-18 00:42:17.289065],
        value: "Success"
      }
    ],
    updated_at: ~N[2018-12-18 00:35:23.424677]
  }

  @filter_label_error %Mockatron.Core.Filter{
    agent_id: 3,
    enable: true,
    id: 3,
    inserted_at: ~N[2018-12-18 00:35:36.184843],
    label: "Error",
    priority: 1,
    response_conditions: [
      %Mockatron.Core.ResponseCondition{
        field_type: "LABEL",
        filter_id: 3,
        id: 3,
        inserted_at: ~N[2018-12-18 00:42:27.718499],
        operator: "EQUALS",
        updated_at: ~N[2018-12-18 00:42:27.718509],
        value: "Error"
      }
    ],
    updated_at: ~N[2018-12-18 00:35:36.184850]
  }

  @filter_http_code_success %Mockatron.Core.Filter{
    agent_id: 3,
    enable: true,
    id: 1,
    inserted_at: ~N[2018-12-18 00:35:23.424666],
    label: "Success",
    priority: 0,
    response_conditions: [
      %Mockatron.Core.ResponseCondition{
        field_type: "HTTP_CODE",
        filter_id: 1,
        id: 1,
        inserted_at: ~N[2018-12-18 00:42:17.289054],
        operator: "EQUALS",
        updated_at: ~N[2018-12-18 00:42:17.289065],
        value: "200"
      }
    ],
    updated_at: ~N[2018-12-18 00:35:23.424677]
  }

  @filter_http_code_error %Mockatron.Core.Filter{
    agent_id: 3,
    enable: true,
    id: 3,
    inserted_at: ~N[2018-12-18 00:35:36.184843],
    label: "Error",
    priority: 1,
    response_conditions: [
      %Mockatron.Core.ResponseCondition{
        field_type: "HTTP_CODE",
        filter_id: 3,
        id: 3,
        inserted_at: ~N[2018-12-18 00:42:27.718499],
        operator: "EQUALS",
        updated_at: ~N[2018-12-18 00:42:27.718509],
        value: "400"
      }
    ],
    updated_at: ~N[2018-12-18 00:35:36.184850]
  }

  @filter_body_success %Mockatron.Core.Filter{
    agent_id: 3,
    enable: true,
    id: 1,
    inserted_at: ~N[2018-12-18 00:35:23.424666],
    label: "Success",
    priority: 0,
    response_conditions: [
      %Mockatron.Core.ResponseCondition{
        field_type: "BODY",
        filter_id: 1,
        id: 1,
        inserted_at: ~N[2018-12-18 00:42:17.289054],
        operator: "CONTAINS",
        updated_at: ~N[2018-12-18 00:42:17.289065],
        value: "Success"
      }
    ],
    updated_at: ~N[2018-12-18 00:35:23.424677]
  }

  @filter_body_error %Mockatron.Core.Filter{
    agent_id: 3,
    enable: true,
    id: 3,
    inserted_at: ~N[2018-12-18 00:35:36.184843],
    label: "Error",
    priority: 1,
    response_conditions: [
      %Mockatron.Core.ResponseCondition{
        field_type: "BODY",
        filter_id: 3,
        id: 3,
        inserted_at: ~N[2018-12-18 00:42:27.718499],
        operator: "CONTAINS",
        updated_at: ~N[2018-12-18 00:42:27.718509],
        value: "Error"
      }
    ],
    updated_at: ~N[2018-12-18 00:35:36.184850]
  }

  @not_found_xml "<mockatron>\n  <code>404</code>\n  <message>Not Found</message>\n  <description>No agent found to meet this request</description>\n</mockatron>"
  @not_found_json "{\n  \"code\":404,\n  \"message\":\"Not Found\",\n  \"description\":\"No agent found to meet this request\"\n}"
  @not_found_text "code: 404\nmessage: Not Found\ndescription: No agent found to meet this request"

  test "Stringify agent" do
    assert Helper.agent_stringify(@signature) == "[User ID: 1] GET http://mockatron.io:80/do"
  end

  test "Stringify agent with content type" do
    assert Helper.agent_stringify(Map.merge(@signature, %{content_type: "application/json"})) ==
             "[User ID: 1] GET http://mockatron.io:80/do [Content Type: application/json]"
  end

  test "Stringify agent with operation" do
    assert Helper.agent_stringify(Map.merge(@signature, %{operation: "doSomething"})) ==
             "[User ID: 1] GET http://mockatron.io:80/do [Operation: doSomething]"
  end

  test "Stringify agent with content type and operation" do
    assert Helper.agent_stringify(
             Map.merge(@signature, %{content_type: "application/json", operation: "doSomething"})
           ) ==
             "[User ID: 1] GET http://mockatron.io:80/do [Content Type: application/json] [Operation: doSomething]"
  end

  test "Generate agent hash with signature" do
    assert Helper.agent_hash(@signature) == @hash_signature
  end

  test "Generate agent hash with signature and filter" do
    assert Helper.agent_hash(@signature, @filter) == @hash_signature_filter
  end

  test "Filter LABEL success" do
    filtered_agent = Helper.filter_responses(@agent, @filter_label_success)
    assert [%{http_code: 200, label: "Success"} | _] = filtered_agent.responses
  end

  test "Filter LABEL error" do
    filtered_agent = Helper.filter_responses(@agent, @filter_label_error)
    assert [%{http_code: 400, label: "Error"} | _] = filtered_agent.responses
  end

  test "Filter HTTP_CODE success" do
    filtered_agent = Helper.filter_responses(@agent, @filter_http_code_success)
    assert [%{http_code: 200, label: "Success"} | _] = filtered_agent.responses
  end

  test "Filter HTTP_CODE error" do
    filtered_agent = Helper.filter_responses(@agent, @filter_http_code_error)
    assert [%{http_code: 400, label: "Error"} | _] = filtered_agent.responses
  end

  test "Filter BODY success" do
    filtered_agent = Helper.filter_responses(@agent, @filter_body_success)
    assert [%{http_code: 200, label: "Success"} | _] = filtered_agent.responses
  end

  test "Filter BODY error" do
    filtered_agent = Helper.filter_responses(@agent, @filter_body_error)
    assert [%{http_code: 400, label: "Error"} | _] = filtered_agent.responses
  end

  describe "Message Default" do
    setup [:sign_in]

    test "Agent Not Found application/json Response", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> get("/v1/mockatron/mock/json")

      assert conn.resp_body == @not_found_json
    end

    test "Agent Not Found text/xml Response", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "text/xml")
        |> get("/v1/mockatron/mock/json")

      assert conn.resp_body == @not_found_xml
    end

    test "Agent Not Found application/soap+xml Response", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/soap+xml")
        |> get("/v1/mockatron/mock/json")

      assert conn.resp_body == @not_found_xml
    end

    test "Agent Not Found text/plain Response", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "text/plain")
        |> get("/v1/mockatron/mock/json")

      assert conn.resp_body == @not_found_text
    end

    test "Agent Not Found no content type Response", %{conn: conn} do
      conn =
        conn
        |> get("/v1/mockatron/mock/json")

      assert conn.resp_body == @not_found_text
    end
  end

  def sign_in(_) do
    {:ok, user} = Auth.create_user(@user_valid_attrs)
    {:ok, token, _} = Guardian.encode_and_sign(user, %{}, token_type: :access)

    conn =
      build_conn()
      |> put_req_header("authorization", "bearer " <> token)

    {:ok, conn: conn}
  end
end
