defmodule Mockatron.Core.Response do
  use Ecto.Schema
  import Ecto.Changeset

  schema "responses" do
    field :body, :string, default: ""
    field :enable, :boolean, default: true
    field :http_code, :integer
    field :label, :string

    belongs_to :agent, Mockatron.Core.Agent

    timestamps()
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> cast(attrs, [:body, :enable, :http_code, :label])
    |> validate_required([:body, :enable, :http_code, :label])
  end
end
