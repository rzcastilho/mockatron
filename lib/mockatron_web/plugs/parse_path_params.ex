defmodule MockatronWeb.ParsePathParams do
  import Plug.Conn
  alias Mockatron.Core.Agent

  def init([]), do: []

  def call(%Plug.Conn{assigns: %{mockatron: %{agent: %{found: false}}}} = conn, _) do
    conn
  end

  def call(%Plug.Conn{assigns: %{mockatron: %{agent: %{agent: %Agent{path_regex: nil}}}}} = conn, _) do
    conn
  end

  def call(%Plug.Conn{assigns: %{mockatron: %{agent: %{agent: %Agent{path_regex: path_regex}}}}, request_path: request_path} = conn, _) do
    conn
    |> assign(
         :path_params,
         path_regex
         |> Regex.compile!()
         |> Regex.named_captures(request_path)
       )
  end

end
