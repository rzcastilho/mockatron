defmodule Mockatron.Core.RequestCondition do
  use Ecto.Schema
  import Ecto.Changeset

  schema "request_conditions" do
    field :field_type, :string
    field :operator, :string
    field :param_name, :string
    field :value, :string

    belongs_to :filter, Mockatron.Core.Filter

    timestamps()
  end

  @doc false
  def changeset(request_condition, attrs) do
    request_condition
    |> cast(attrs, [:field_type, :param_name, :operator, :value])
    |> validate_required([:field_type, :operator, :value])
    |> validate_inclusion(:field_type, ["BODY", "HEADER", "QUERY_PARAM", "PATH_PARAM"])
    |> validate_inclusion(:operator, [
      "EQUALS",
      "NOTEQUALS",
      "CONTAINS",
      "STARTSWITH",
      "ENDSWITH",
      "REGEX"
    ])
  end
end
