defmodule Mockatron.Core do
  @moduledoc """
  The Core context.
  """

  import Ecto.Query, warn: false
  alias Mockatron.Repo

  alias Mockatron.Core.Agent

  @doc """
  Returns the list of agents.

  ## Examples

      iex> list_agents()
      [%Agent{}, ...]

  """
  def list_agents do
    Repo.all(Agent)
  end

  @doc """
  Gets a single agent.

  Raises `Ecto.NoResultsError` if the Agent does not exist.

  ## Examples

      iex> get_agent!(123)
      %Agent{}

      iex> get_agent!(456)
      ** (Ecto.NoResultsError)

  """
  def get_agent!(id), do: Repo.get!(Agent, id)

  @doc """
  Creates a agent.

  ## Examples

      iex> create_agent(%{field: value})
      {:ok, %Agent{}}

      iex> create_agent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_agent(attrs \\ %{}, user) do
    user
    |> Ecto.build_assoc(:agents)
    |> Agent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a agent.

  ## Examples

      iex> update_agent(agent, %{field: new_value})
      {:ok, %Agent{}}

      iex> update_agent(agent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_agent(%Agent{} = agent, attrs) do
    agent
    |> Agent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a agent.

  ## Examples

      iex> delete_agent(agent)
      {:ok, %Agent{}}

      iex> delete_agent(agent)
      {:error, %Ecto.Changeset{}}

  """
  def delete_agent(%Agent{} = agent) do
    Repo.delete(agent)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking agent changes.

  ## Examples

      iex> change_agent(agent)
      %Ecto.Changeset{data: %Agent{}}

  """
  def change_agent(%Agent{} = agent, attrs \\ %{}) do
    Agent.changeset(agent, attrs)
  end

  def list_agents_by_user(user) do
    Ecto.assoc(user, :agents)
    |> Repo.all()
  end

  def get_agent_from_user(id, user) do
    Repo.one(from a in Agent, select: a, where: ^id == a.id and ^user.id == a.user_id)
  end

  alias Mockatron.Core.Response

  @doc """
  Returns the list of responses.

  ## Examples

      iex> list_responses()
      [%Response{}, ...]

  """
  def list_responses do
    Repo.all(Response)
  end

  @doc """
  Gets a single response.

  Raises `Ecto.NoResultsError` if the Response does not exist.

  ## Examples

      iex> get_response!(123)
      %Response{}

      iex> get_response!(456)
      ** (Ecto.NoResultsError)

  """
  def get_response!(id), do: Repo.get!(Response, id)

  @doc """
  Creates a response.

  ## Examples

      iex> create_response(%{field: value})
      {:ok, %Response{}}

      iex> create_response(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_response(attrs \\ %{}, agent) do
    agent
    |> Ecto.build_assoc(:responses)
    |> Response.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a response.

  ## Examples

      iex> update_response(response, %{field: new_value})
      {:ok, %Response{}}

      iex> update_response(response, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_response(%Response{} = response, attrs) do
    response
    |> Response.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a response.

  ## Examples

      iex> delete_response(response)
      {:ok, %Response{}}

      iex> delete_response(response)
      {:error, %Ecto.Changeset{}}

  """
  def delete_response(%Response{} = response) do
    Repo.delete(response)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking response changes.

  ## Examples

      iex> change_response(response)
      %Ecto.Changeset{data: %Response{}}

  """
  def change_response(%Response{} = response, attrs \\ %{}) do
    Response.changeset(response, attrs)
  end

  def list_responses_by_agent(agent) do
    Ecto.assoc(agent, :responses)
    |> Repo.all()
  end

  def get_response_from_agent(id, agent) do
    Repo.one(from a in Response, select: a, where: ^id == a.id and ^agent.id == a.agent_id)
  end

  alias Mockatron.Core.Filter

  @doc """
  Returns the list of filters.

  ## Examples

      iex> list_filters()
      [%Filter{}, ...]

  """
  def list_filters do
    Repo.all(Filter)
  end

  @doc """
  Gets a single filter.

  Raises `Ecto.NoResultsError` if the Filter does not exist.

  ## Examples

      iex> get_filter!(123)
      %Filter{}

      iex> get_filter!(456)
      ** (Ecto.NoResultsError)

  """
  def get_filter!(id), do: Repo.get!(Filter, id)

  @doc """
  Creates a filter.

  ## Examples

      iex> create_filter(%{field: value})
      {:ok, %Filter{}}

      iex> create_filter(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_filter(attrs \\ %{}, agent) do
    agent
    |> Ecto.build_assoc(:filters)
    |> Filter.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a filter.

  ## Examples

      iex> update_filter(filter, %{field: new_value})
      {:ok, %Filter{}}

      iex> update_filter(filter, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_filter(%Filter{} = filter, attrs) do
    filter
    |> Filter.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a filter.

  ## Examples

      iex> delete_filter(filter)
      {:ok, %Filter{}}

      iex> delete_filter(filter)
      {:error, %Ecto.Changeset{}}

  """
  def delete_filter(%Filter{} = filter) do
    Repo.delete(filter)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking filter changes.

  ## Examples

      iex> change_filter(filter)
      %Ecto.Changeset{data: %Filter{}}

  """
  def change_filter(%Filter{} = filter, attrs \\ %{}) do
    Filter.changeset(filter, attrs)
  end

  def list_filters_by_agent(agent) do
    Ecto.assoc(agent, :filters)
    |> Repo.all()
  end

  def get_filter_from_agent(id, agent) do
    Repo.one(from a in Filter, select: a, where: ^id == a.id and ^agent.id == a.agent_id)
  end

  alias Mockatron.Core.RequestCondition

  @doc """
  Returns the list of request_conditions.

  ## Examples

      iex> list_request_conditions()
      [%RequestCondition{}, ...]

  """
  def list_request_conditions do
    Repo.all(RequestCondition)
  end

  @doc """
  Gets a single request_condition.

  Raises `Ecto.NoResultsError` if the Request condition does not exist.

  ## Examples

      iex> get_request_condition!(123)
      %RequestCondition{}

      iex> get_request_condition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_request_condition!(id), do: Repo.get!(RequestCondition, id)

  @doc """
  Creates a request_condition.

  ## Examples

      iex> create_request_condition(%{field: value})
      {:ok, %RequestCondition{}}

      iex> create_request_condition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_request_condition(attrs \\ %{}, filter) do
    filter
    |> Ecto.build_assoc(:request_conditions)
    |> RequestCondition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a request_condition.

  ## Examples

      iex> update_request_condition(request_condition, %{field: new_value})
      {:ok, %RequestCondition{}}

      iex> update_request_condition(request_condition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_request_condition(%RequestCondition{} = request_condition, attrs) do
    request_condition
    |> RequestCondition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a request_condition.

  ## Examples

      iex> delete_request_condition(request_condition)
      {:ok, %RequestCondition{}}

      iex> delete_request_condition(request_condition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_request_condition(%RequestCondition{} = request_condition) do
    Repo.delete(request_condition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking request_condition changes.

  ## Examples

      iex> change_request_condition(request_condition)
      %Ecto.Changeset{data: %RequestCondition{}}

  """
  def change_request_condition(%RequestCondition{} = request_condition, attrs \\ %{}) do
    RequestCondition.changeset(request_condition, attrs)
  end

  def list_request_conditions_by_filter(filter) do
    Ecto.assoc(filter, :request_conditions)
    |> Repo.all()
  end

  def get_request_condition_from_filter(id, filter) do
    Repo.one(
      from a in RequestCondition, select: a, where: ^id == a.id and ^filter.id == a.filter_id
    )
  end

  alias Mockatron.Core.ResponseCondition

  @doc """
  Returns the list of response_conditions.

  ## Examples

      iex> list_response_conditions()
      [%ResponseCondition{}, ...]

  """
  def list_response_conditions do
    Repo.all(ResponseCondition)
  end

  @doc """
  Gets a single response_condition.

  Raises `Ecto.NoResultsError` if the Response condition does not exist.

  ## Examples

      iex> get_response_condition!(123)
      %ResponseCondition{}

      iex> get_response_condition!(456)
      ** (Ecto.NoResultsError)

  """
  def get_response_condition!(id), do: Repo.get!(ResponseCondition, id)

  @doc """
  Creates a response_condition.

  ## Examples

      iex> create_response_condition(%{field: value})
      {:ok, %ResponseCondition{}}

      iex> create_response_condition(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_response_condition(attrs \\ %{}, filter) do
    filter
    |> Ecto.build_assoc(:response_conditions)
    |> ResponseCondition.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a response_condition.

  ## Examples

      iex> update_response_condition(response_condition, %{field: new_value})
      {:ok, %ResponseCondition{}}

      iex> update_response_condition(response_condition, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_response_condition(%ResponseCondition{} = response_condition, attrs) do
    response_condition
    |> ResponseCondition.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a response_condition.

  ## Examples

      iex> delete_response_condition(response_condition)
      {:ok, %ResponseCondition{}}

      iex> delete_response_condition(response_condition)
      {:error, %Ecto.Changeset{}}

  """
  def delete_response_condition(%ResponseCondition{} = response_condition) do
    Repo.delete(response_condition)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking response_condition changes.

  ## Examples

      iex> change_response_condition(response_condition)
      %Ecto.Changeset{data: %ResponseCondition{}}

  """
  def change_response_condition(%ResponseCondition{} = response_condition, attrs \\ %{}) do
    ResponseCondition.changeset(response_condition, attrs)
  end

  def list_response_conditions_by_filter(filter) do
    Ecto.assoc(filter, :response_conditions)
    |> Repo.all()
  end

  def get_response_condition_from_filter(id, filter) do
    Repo.one(
      from a in ResponseCondition, select: a, where: ^id == a.id and ^filter.id == a.filter_id
    )
  end
end
