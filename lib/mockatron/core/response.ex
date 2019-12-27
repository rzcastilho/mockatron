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
    |> cast(attrs, [:label, :http_code, :body, :enable])
    |> validate_required([:label, :http_code, :body, :enable])
  end

end
