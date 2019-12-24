defmodule Mockatron.AuthTest do
  use Mockatron.DataCase

  alias Mockatron.Auth

  describe "users" do
    alias Mockatron.Auth.User

    @valid_attrs %{email: "test@mockatron.io", password: "Welcome1", password_confirmation: "Welcome1", verified: true}
    @update_attrs %{email: "contact@mockatron.io", password: "Welcome1", password_confirmation: "Welcome1", verified: false}
    @invalid_attrs %{email: nil, password_hash: nil, verified: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Auth.create_user()

      user
      |> Map.put(:password, nil)
      |> Map.put(:password_confirmation, nil)
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Auth.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Auth.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Auth.create_user(@valid_attrs)
      assert user.email == "test@mockatron.io"
      assert user.verified == true
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Auth.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Auth.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "contact@mockatron.io"
      assert user.verified == false
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, @invalid_attrs)
      assert user == Auth.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Auth.change_user(user)
    end

    test "get_by_email/1 returns user" do
      user_fixture()
      assert {:ok, user} = Auth.get_by_email("test@mockatron.io")
    end

    test "get_by_email/1 returns email_not_found" do
      assert {:error, :email_not_found} = Auth.get_by_email("noexists@mockatron.io")
    end

    test "token_sign_in/2 returns user" do
      user_fixture()
      assert {:ok, token, jwt} = Auth.token_sign_in("test@mockatron.io", "Welcome1")
    end

    test "token_sign_in/2 returns error" do
      user_fixture()
      assert {:error, _} = Auth.token_sign_in("test@mockatron.io", "welcome1")
    end
    
  end
end
