defmodule Mockatron.Core.Filter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "filters" do
    field :enable, :boolean, default: true
    field :label, :string
    field :priority, :integer

    belongs_to :agent, Mockatron.Core.Agent

    has_many :request_conditions, Mockatron.Core.RequestCondition
    has_many :response_conditions, Mockatron.Core.ResponseCondition

    timestamps()
  end

  @doc false
  def changeset(filter, attrs) do
    filter
    |> cast(attrs, [:label, :priority, :enable])
    |> validate_required([:label, :priority, :enable])
  end
end
