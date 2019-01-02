defmodule MockatronWeb.OperationView do
  use MockatronWeb, :view
  alias MockatronWeb.OperationView

  def render("index.json", %{operations: operations}) do
    %{data: render_many(operations, OperationView, "operation.json")}
  end

  def render("show.json", %{operation: operation}) do
    %{data: render_one(operation, OperationView, "operation.json")}
  end

  def render("operation.json", %{operation: operation}) do
    %{id: operation.id,
      name: operation.name,
      input_message: operation.input_message,
      output_message: operation.output_message,
      responder: operation.responder}
  end
end
