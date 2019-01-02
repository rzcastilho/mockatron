defmodule MockatronWeb.RequestConditionView do
  use MockatronWeb, :view
  alias MockatronWeb.RequestConditionView

  def render("index.json", %{request_conditions: request_conditions}) do
    %{data: render_many(request_conditions, RequestConditionView, "request_condition.json")}
  end

  def render("show.json", %{request_condition: request_condition}) do
    %{data: render_one(request_condition, RequestConditionView, "request_condition.json")}
  end

  def render("request_condition.json", %{request_condition: request_condition}) do
    %{id: request_condition.id,
      field_type: request_condition.field_type,
      operator: request_condition.operator,
      header_or_query_param: request_condition.header_or_query_param,
      value: request_condition.value}
  end
end
