defmodule MockatronWeb.MockController do
  use MockatronWeb, :controller
  import MockatronWeb.Utils.Helper

  def response(%Plug.Conn{assigns: %{mockatron: %{agent: %{found: false}}}} = conn, _params) do
    conn
    |> send_agent_not_found_resp
  end

  def response(
        %Plug.Conn{
          assigns: %{
            mockatron: %{
              agent: %{found: true, agent: %{content_type: content_type}},
              responder: %{found: true, pid: responder, module: module}
            }
          }
        } = conn,
        _params
      ) do
    response = module.response(responder, conn)

    conn
    |> put_resp_content_type(content_type)
    |> send_resp(response.http_code, response.body)
  end
end
