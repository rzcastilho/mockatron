defmodule Mockatron.Core.Agent do
  use Ecto.Schema
  import Ecto.Changeset

  @regex_path_params_exists ~r"<[^/]+>"
  @regex_path_params ~r/<([[:alnum:]_]+?(?=>))>|<([[:alnum:]_]+):(.+?(?=>))>/

  schema "agents" do
    field :content_type, :string
    field :host, :string
    field :method, :string
    field :path, :string
    field :path_regex, :string
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
    |> cast(attrs, [:method, :protocol, :host, :port, :path, :content_type, :responder, :operation, :path_regex])
    |> validate_required([:method, :protocol, :host, :port, :path, :responder])
    |> validate_inclusion(:method, ["OPTIONS", "GET", "HEAD", "POST", "PUT", "DELETE", "TRACE", "CONNECT"])
    |> validate_inclusion(:responder, ["SEQUENTIAL", "RANDOM"])
    |> put_path_regex
  end

  def put_path_regex(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{path: path}} ->
        case Regex.match?(@regex_path_params_exists, path) do
          true ->
            path_regex = Regex.scan(@regex_path_params, path)
            |> Enum.reduce(path, &transform_path_param/2)
            put_change(changeset, :path_regex, "^#{path_regex}$")
          _ ->
            changeset
        end
      _ ->
        changeset
    end
  end

  def transform_path_param([snippet, name], path), do: String.replace(path, snippet, "(?<#{name}>[^/]+)")
  def transform_path_param([snippet, _, name, regex], path), do: String.replace(path, snippet, "(?<#{name}>#{regex})")

end
