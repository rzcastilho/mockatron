defmodule MockatronWeb.InspectConn do

  def init([]), do: []

  def call(conn, _) do
    IO.inspect conn
    conn
  end

end
