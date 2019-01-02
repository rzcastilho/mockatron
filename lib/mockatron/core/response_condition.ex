defmodule Mockatron.Core.ResponseCondition do
  use Ecto.Schema
  import Ecto.Changeset


  schema "response_conditions" do
    field :field_type, :string
    field :operator, :string
    field :value, :string

    belongs_to :filter, Mockatron.Core.Filter

    timestamps()
  end

  @doc false
  def changeset(response_condition, attrs) do
    response_condition
    |> cast(attrs, [:field_type, :operator, :value])
    |> validate_required([:field_type, :operator, :value])
    |> validate_inclusion(:field_type, ["LABEL", "HTTP_CODE", "BODY"])
    |> validate_inclusion(:operator, ["EQUALS", "NOTEQUALS", "CONTAINS", "STARTSWITH", "ENDSWITH", "REGEX"])
  end
end
