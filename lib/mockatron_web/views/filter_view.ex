defmodule MockatronWeb.FilterView do
  use MockatronWeb, :view
  alias MockatronWeb.FilterView

  def render("index.json", %{filters: filters}) do
    %{data: render_many(filters, FilterView, "filter.json")}
  end

  def render("show.json", %{filter: filter}) do
    %{data: render_one(filter, FilterView, "filter.json")}
  end

  def render("filter.json", %{filter: filter}) do
    %{id: filter.id, enable: filter.enable, label: filter.label, priority: filter.priority}
  end
end
