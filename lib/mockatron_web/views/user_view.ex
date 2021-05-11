defmodule MockatronWeb.UserView do
  use MockatronWeb, :view

  def render("jwt.json", %{jwt: jwt}) do
    %{jwt: jwt}
  end
end
