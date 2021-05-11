defmodule Mockatron.Repo.Migrations.CreateAgents do
  use Ecto.Migration

  def change do
    create table(:agents) do
      add :content_type, :string
      add :host, :string
      add :method, :string
      add :path, :string
      add :path_regex, :string
      add :port, :integer
      add :protocol, :string
      add :responder, :string
      add :operation, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:agents, [:user_id])
  end
end
