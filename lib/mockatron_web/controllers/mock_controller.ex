defmodule MockatronWeb.MockController do
  use MockatronWeb, :controller
  import MockatronWeb.Utils.Helper
  alias Mockatron.Core.Response

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
          },
          body_params: request
        } = conn,
        _params
      ) do
    response = module.response(responder)
    bindings = case request do
      %{xml: xml} ->
        [request: xml]
      %{} = json when json != %{} ->
        [request: json]
      _ ->
        nil
    end

    conn
    |> do_response(response, content_type, bindings)
  end
  
  defp do_response(conn, %Response{template: true, body: template,  http_code: http_code}, content_type, bindings) do
    body = EEx.eval_string(template, bindings, trim: true)
    conn
    |> put_resp_content_type(content_type)
    |> send_resp(http_code, body)
  rescue
    error ->
      send_error_processing_template_resp(conn, error, template)
  end
  
  defp do_response(conn, %Response{body: body,  http_code: http_code}, content_type, _bindings) do
    conn
    |> put_resp_content_type(content_type)
    |> send_resp(http_code, body)
  end
  
end
