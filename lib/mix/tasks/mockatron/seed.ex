defmodule Mix.Tasks.Mockatron.Seed do
  use Mix.Task
  import Ecto.Query
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]
  alias Mockatron.Repo
  alias Mockatron.Auth.User
  alias Mockatron.Core.Agent
  alias Mockatron.Core.Response
  alias Mockatron.Core.Filter
  alias Mockatron.Core.RequestCondition
  alias Mockatron.Core.ResponseCondition

  def run(_) do
    Mix.Task.run "app.start", []
    seed(Mix.env)
  end

  def seed(:test) do
    # Any data for test goes here
    # i.e. Repo.insert!(%MyApp.User{}, %{ first_name: "Alex, last_name: "Garibay" })
  end

  def seed(:dev) do
    case Repo.get_by(User, email: "test@mockatron.io") do
      nil ->
        %{id: user_id} = Repo.insert!(%User{email: "test@mockatron.io", password_hash: hashpwsalt("Welcome1")})

        case Repo.get_by(Agent, path: "/sequential") do
          nil ->
            %{id: agent_id} = Repo.insert!(%Agent{user_id: user_id, method: "GET", protocol: "http", host: "localhost", port: 4000, path: "/sequential", content_type: "application/json", responder: "SEQUENTIAL"})
            Repo.insert!(%Response{agent_id: agent_id, label: "Success", http_code: 200, body: "{\"code\":\"0\",\"description\":\"Success\"}", enable: true})
            Repo.insert!(%Response{agent_id: agent_id, label: "Error", http_code: 400, body: "{\"code\":\"99\",\"description\":\"Error\"}", enable: true})
          _ ->
            :exists
        end

        case Repo.get_by(Agent, path: "/random") do
          nil ->
            %{id: agent_id} = Repo.insert!(%Agent{user_id: user_id, method: "GET", protocol: "http", host: "localhost", port: 4000, path: "/random", content_type: "application/json", responder: "RANDOM"})
            Repo.insert!(%Response{agent_id: agent_id, label: "Success", http_code: 200, body: "{\"code\":\"0\",\"description\":\"Success\"}", enable: true})
            Repo.insert!(%Response{agent_id: agent_id, label: "Error", http_code: 400, body: "{\"code\":\"99\",\"description\":\"Error\"}", enable: true})
          _ ->
            :exists
        end

        case Repo.get_by(Agent, path: "/filter/sequential") do
          nil ->
            %{id: agent_id} = Repo.insert!(%Agent{user_id: user_id, method: "GET", protocol: "http", host: "localhost", port: 4000, path: "/filter/sequential", content_type: "application/json", responder: "SEQUENTIAL"})
            Repo.insert!(%Response{agent_id: agent_id, label: "Success", http_code: 200, body: "{\"code\":\"0\",\"description\":\"Success\"}", enable: true})
            Repo.insert!(%Response{agent_id: agent_id, label: "Success", http_code: 200, body: "{\"code\":\"0\",\"description\":\"Success Again\"}", enable: true})
            Repo.insert!(%Response{agent_id: agent_id, label: "Error", http_code: 400, body: "{\"code\":\"99\",\"description\":\"Error\"}", enable: true})
            Repo.insert!(%Response{agent_id: agent_id, label: "Error", http_code: 500, body: "{\"code\":\"99\",\"description\":\"Error Again\"}", enable: true})
            %{id: filter_id} = Repo.insert!(%Filter{agent_id: agent_id, label: "Success", priority: 0})
            Repo.insert!(%RequestCondition{filter_id: filter_id, field_type: "QUERY_PARAM", header_or_query_param: "status", operator: "EQUALS", value: "success"})
            Repo.insert!(%ResponseCondition{filter_id: filter_id, field_type: "LABEL", operator: "EQUALS", value: "Success"})
            %{id: filter_id} = Repo.insert!(%Filter{agent_id: agent_id, label: "Error", priority: 1})
            Repo.insert!(%RequestCondition{filter_id: filter_id, field_type: "QUERY_PARAM", header_or_query_param: "status", operator: "EQUALS", value: "error"})
            Repo.insert!(%ResponseCondition{filter_id: filter_id, field_type: "LABEL", operator: "EQUALS", value: "Error"})
          _ ->
            :exists
        end

        case Repo.get_by(Agent, path: "/filter/random") do
          nil ->
            %{id: agent_id} = Repo.insert!(%Agent{user_id: user_id, method: "GET", protocol: "http", host: "localhost", port: 4000, path: "/filter/random", content_type: "application/json", responder: "RANDOM"})
            Repo.insert!(%Response{agent_id: agent_id, label: "Success", http_code: 200, body: "{\"code\":\"0\",\"description\":\"Success\"}", enable: true})
            Repo.insert!(%Response{agent_id: agent_id, label: "Error", http_code: 400, body: "{\"code\":\"99\",\"description\":\"Error\"}", enable: true})
            Repo.insert!(%Response{agent_id: agent_id, label: "Success", http_code: 200, body: "{\"code\":\"0\",\"description\":\"Success Again\"}", enable: true})
            Repo.insert!(%Response{agent_id: agent_id, label: "Error", http_code: 500, body: "{\"code\":\"99\",\"description\":\"Error Again\"}", enable: true})
            %{id: filter_id} = Repo.insert!(%Filter{agent_id: agent_id, label: "Success", priority: 0})
            Repo.insert!(%RequestCondition{filter_id: filter_id, field_type: "QUERY_PARAM", header_or_query_param: "status", operator: "EQUALS", value: "success"})
            Repo.insert!(%ResponseCondition{filter_id: filter_id, field_type: "LABEL", operator: "EQUALS", value: "Success"})
            %{id: filter_id} = Repo.insert!(%Filter{agent_id: agent_id, label: "Error", priority: 1})
            Repo.insert!(%RequestCondition{filter_id: filter_id, field_type: "QUERY_PARAM", header_or_query_param: "status", operator: "EQUALS", value: "error"})
            Repo.insert!(%ResponseCondition{filter_id: filter_id, field_type: "LABEL", operator: "EQUALS", value: "Error"})
          _ ->
            :exists
        end

        case Repo.one(from a in Agent, select: a, where: "/calculator.asmx" == a.path and "text/xml" == a.content_type and "\"http://tempuri.org/Add\"" == a.operation) do
          nil ->
            %{id: agent_id} = Repo.insert!(%Agent{user_id: user_id, method: "POST", protocol: "http", host: "localhost", port: 4000, path: "/calculator.asmx", content_type: "text/xml", responder: "SEQUENTIAL", operation: "\"http://tempuri.org/Add\""})
            Repo.insert!(%Response{agent_id: agent_id, label: "Success", http_code: 200, body: "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">\n   <soap:Body>\n      <AddResponse xmlns=\"http://tempuri.org/\">\n         <AddResult>20</AddResult>\n      </AddResponse>\n   </soap:Body>\n</soap:Envelope>", enable: true})
          _ ->
            :exists
        end

        case Repo.one(from a in Agent, select: a, where: "/calculator.asmx" == a.path and "text/xml" == a.content_type and "\"http://tempuri.org/Divide\"" == a.operation) do
          nil ->
            %{id: agent_id} = Repo.insert!(%Agent{user_id: user_id, method: "POST", protocol: "http", host: "localhost", port: 4000, path: "/calculator.asmx", content_type: "text/xml", responder: "SEQUENTIAL", operation: "\"http://tempuri.org/Divide\""})
            Repo.insert!(%Response{agent_id: agent_id, label: "Success", http_code: 200, body: "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">\n   <soap:Body>\n      <DivideResponse xmlns=\"http://tempuri.org/\">\n         <DivideResult>5</DivideResult>\n      </DivideResponse>\n   </soap:Body>\n</soap:Envelope>", enable: true})
          _ ->
            :exists
        end

        case Repo.one(from a in Agent, select: a, where: "/calculator.asmx" == a.path and "text/xml" == a.content_type and "\"http://tempuri.org/Multiply\"" == a.operation) do
          nil ->
            %{id: agent_id} = Repo.insert!(%Agent{user_id: user_id, method: "POST", protocol: "http", host: "localhost", port: 4000, path: "/calculator.asmx", content_type: "text/xml", responder: "SEQUENTIAL", operation: "\"http://tempuri.org/Multiply\""})
            Repo.insert!(%Response{agent_id: agent_id, label: "Success", http_code: 200, body: "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">\n   <soap:Body>\n      <MultiplyResponse xmlns=\"http://tempuri.org/\">\n         <MultiplyResult>16</MultiplyResult>\n      </MultiplyResponse>\n   </soap:Body>\n</soap:Envelope>", enable: true})
          _ ->
            :exists
        end

        case Repo.one(from a in Agent, select: a, where: "/calculator.asmx" == a.path and "text/xml" == a.content_type and "\"http://tempuri.org/Subtract\"" == a.operation) do
          nil ->
            %{id: agent_id} = Repo.insert!(%Agent{user_id: user_id, method: "POST", protocol: "http", host: "localhost", port: 4000, path: "/calculator.asmx", content_type: "text/xml", responder: "SEQUENTIAL", operation: "\"http://tempuri.org/Subtract\""})
            Repo.insert!(%Response{agent_id: agent_id, label: "Success", http_code: 200, body: "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">\n   <soap:Body>\n      <SubtractResponse xmlns=\"http://tempuri.org/\">\n         <SubtractResult>10</SubtractResult>\n      </SubtractResponse>\n   </soap:Body>\n</soap:Envelope>", enable: true})
          _ ->
            :exists
        end
      _ ->
        :exists
    end

  end

  def seed(:prod) do
    # Proceed with caution for production
  end

end
