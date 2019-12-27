defmodule MockatronWeb.Init do
  import Plug.Conn
  alias MockatronWeb.Utils.Helper
  alias Mockatron.AgentResponder
  alias Mockatron.AgentResponder.Signature
  alias Mockatron.AgentResponder.Agent

  @mockatron_target_protocol "mockatron-target-protocol"
  @mockatron_target_hostname "mockatron-target-hostname"
  @mockatron_target_port "mockatron-target-port"

  def init([]), do: []

  def call(%Plug.Conn{method: method, scheme: scheme, host: host, port: port, request_path: path, private: %{:guardian_default_claims => %{"sub" => user_id}}} = conn, _) do
    protocol = case get_req_header(conn, @mockatron_target_protocol) do
      [] -> Atom.to_string(scheme)
      [target_protocol] -> target_protocol
    end
    host = case get_req_header(conn, @mockatron_target_hostname) do
      [] -> host
      [target_hostname] -> target_hostname
    end
    port = case get_req_header(conn, @mockatron_target_port) do
      [] -> port
      [target_port] -> String.to_integer(target_port)
    end
    signature = %Signature{user_id: String.to_integer(user_id), method: method,protocol: protocol, host: host, port: port, path: path}
    signature = case get_req_header(conn, "content-type") do
      [] ->
        signature
      [content_type] ->
        Map.merge(signature, %{content_type: String.split(content_type, ";") |> hd})
    end
    signature = case get_req_header(conn, "soapaction") do
      [] ->
        signature
      [soapaction] ->
        Map.merge(signature, %{operation: soapaction})
    end
    conn
    |> assign(:mockatron, %AgentResponder{signature: signature, agent: %Agent{hash: Helper.agent_hash(signature)}})
  end

end
