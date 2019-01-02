defmodule Mockatron.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses) do
      add :label, :string
      add :http_code, :integer
      add :body, :text
      add :enable, :boolean, default: false, null: false
      add :agent_id, references(:agents, on_delete: :delete_all)

      timestamps()
    end

    create index(:responses, [:agent_id])
  end
end
