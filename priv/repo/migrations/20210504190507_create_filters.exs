defmodule Mockatron.Repo.Migrations.CreateFilters do
  use Ecto.Migration

  def change do
    create table(:filters) do
      add :enable, :boolean, default: false, null: false
      add :label, :string
      add :priority, :integer
      add :agent_id, references(:agents, on_delete: :delete_all)

      timestamps()
    end

    create index(:filters, [:agent_id])
  end
end
