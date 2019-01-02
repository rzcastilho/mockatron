defmodule Mockatron.Repo.Migrations.CreateResponseConditions do
  use Ecto.Migration

  def change do
    create table(:response_conditions) do
      add :field_type, :string
      add :operator, :string
      add :value, :string
      add :filter_id, references(:filters, on_delete: :delete_all)

      timestamps()
    end

    create index(:response_conditions, [:filter_id])
  end
end
