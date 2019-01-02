defmodule Mockatron.Repo.Migrations.CreateAgents do
  use Ecto.Migration

  def change do
    create table(:agents) do
      add :method, :string
      add :protocol, :string
      add :host, :string
      add :port, :integer
      add :path, :string
      add :operation, :string
      add :content_type, :string
      add :responder, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:agents, [:user_id])
  end
end
