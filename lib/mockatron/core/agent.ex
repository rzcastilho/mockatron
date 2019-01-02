defmodule Mockatron.Core.Agent do
  use Ecto.Schema
  import Ecto.Changeset


  schema "agents" do
    field :content_type, :string
    field :host, :string
    field :method, :string
    field :path, :string
    field :port, :integer
    field :protocol, :string
    field :responder, :string
    field :operation, :string

    belongs_to :user, Mockatron.Auth.User

    has_many :responses, Mockatron.Core.Response
    has_many :filters, Mockatron.Core.Filter

    timestamps()
  end

  @doc false
  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:method, :protocol, :host, :port, :path, :content_type, :responder, :operation])
    |> validate_required([:method, :protocol, :host, :port, :path, :responder])
    |> validate_inclusion(:method, ["OPTIONS", "GET", "HEAD", "POST", "PUT", "DELETE", "TRACE", "CONNECT"])
    |> validate_inclusion(:responder, ["SEQUENTIAL", "RANDOM"])
  end
end
