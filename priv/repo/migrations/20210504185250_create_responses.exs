defmodule Mockatron.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses) do
      add :body, :text
      add :template, :boolean, default: false, null: false
      add :enable, :boolean, default: false, null: false
      add :http_code, :integer
      add :label, :string
      add :agent_id, references(:agents, on_delete: :delete_all)

      timestamps()
    end

    create index(:responses, [:agent_id])
  end
end
