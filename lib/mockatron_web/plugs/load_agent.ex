defmodule MockatronWeb.LoadAgent do
  import Plug.Conn
  alias Mockatron.Core.Agent
  alias MockatronWeb.Utils.Helper

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(%Plug.Conn{assigns: %{mockatron: %{agent: %{cache: true}}}} = conn, _) do
    conn
  end

  def call(
        %Plug.Conn{
          assigns: %{
            mockatron:
              %{agent: %{cache: false, hash: hash} = agent, signature: signature} = mockatron
          }
        } = conn,
        repo
      ) do
    case Helper.load_agent(signature, repo) do
      %Agent{} = agent_found ->
        Cachex.put(:agent, hash, %{agent: agent_found})

        conn
        |> assign(
          :mockatron,
          Map.merge(mockatron, %{agent: Map.merge(%{agent | found: true}, %{agent: agent_found})})
        )

      nil ->
        conn
    end
  end
end
