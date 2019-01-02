defmodule MockatronWeb.ResponseView do
  use MockatronWeb, :view
  alias MockatronWeb.ResponseView

  def render("index.json", %{responses: responses}) do
    %{data: render_many(responses, ResponseView, "response.json")}
  end

  def render("show.json", %{response: response}) do
    %{data: render_one(response, ResponseView, "response.json")}
  end

  def render("response.json", %{response: response}) do
    %{id: response.id,
      label: response.label,
      http_code: response.http_code,
      body: response.body,
      enable: response.enable}
  end
end
