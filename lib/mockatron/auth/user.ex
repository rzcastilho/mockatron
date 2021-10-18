defmodule Mockatron.Auth.User do
  use Ecto.Schema
  import Ecto.Changeset
  # import Bcrypt, only: [hash_pwd_salt: 1]
  alias Argon2

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :verified, :boolean, default: false
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    has_many :agents, Mockatron.Core.Agent

    timestamps()
  end

  @doc false
  def changeset(user, %{verified: true} = attrs) do
    user
    |> cast(attrs, [:verified])
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :password_confirmation, :verified])
    |> validate_required([:email, :password, :password_confirmation, :verified])
    |> validate_format(
      :email,
      ~r/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    )
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> unique_constraint(:email)
    |> put_password_hash
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end
end
