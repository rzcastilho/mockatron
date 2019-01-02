defmodule MockatronWeb.ResponseConditionView do
  use MockatronWeb, :view
  alias MockatronWeb.ResponseConditionView

  def render("index.json", %{response_conditions: response_conditions}) do
    %{data: render_many(response_conditions, ResponseConditionView, "response_condition.json")}
  end

  def render("show.json", %{response_condition: response_condition}) do
    %{data: render_one(response_condition, ResponseConditionView, "response_condition.json")}
  end

  def render("response_condition.json", %{response_condition: response_condition}) do
    %{id: response_condition.id,
      field_type: response_condition.field_type,
      operator: response_condition.operator,
      value: response_condition.value}
  end
end
