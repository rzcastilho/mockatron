defmodule Mockatron.Repo.Migrations.CreateRequestConditions do
  use Ecto.Migration

  def change do
    create table(:request_conditions) do
      add :field_type, :string
      add :operator, :string
      add :param_name, :string
      add :value, :string
      add :filter_id, references(:filters, on_delete: :delete_all)

      timestamps()
    end

    create index(:request_conditions, [:filter_id])
  end
end
