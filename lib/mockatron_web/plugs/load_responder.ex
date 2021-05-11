defmodule MockatronWeb.LoadResponder do
  import Plug.Conn
  alias Mockatron.Responder.Random
  alias Mockatron.Responder.Sequential
  alias MockatronWeb.Utils.Helper

  def init([]), do: []

  def call(%Plug.Conn{assigns: %{mockatron: %{responder: %{cache: true}}}} = conn, _) do
    conn
  end

  def call(
        %Plug.Conn{
          assigns: %{
            mockatron:
              %{
                responder: %{cache: false, hash: hash, filter: filter} = responder,
                agent: %{agent: agent}
              } = mockatron
          }
        } = conn,
        _
      ) do
    agent =
      case filter do
        nil -> agent
        [] -> agent
        _ -> Helper.filter_responses(agent, filter)
      end

    case agent do
      %Mockatron.Core.Agent{responder: "RANDOM"} = agent ->
        case Random.start_link(agent) do
          {:ok, pid} ->
            Cachex.put(:responder, hash, %{pid: pid, module: Mockatron.Responder.Random})

            conn
            |> assign(
              :mockatron,
              Map.merge(mockatron, %{
                responder:
                  Map.merge(%{responder | found: true}, %{
                    pid: pid,
                    module: Mockatron.Responder.Random
                  })
              })
            )

          _ ->
            conn
        end

      %Mockatron.Core.Agent{responder: "SEQUENTIAL"} = agent ->
        case Sequential.start_link(agent) do
          {:ok, pid} ->
            Cachex.put(:responder, hash, %{pid: pid, module: Mockatron.Responder.Sequential})

            conn
            |> assign(
              :mockatron,
              Map.merge(mockatron, %{
                responder:
                  Map.merge(%{responder | found: true}, %{
                    pid: pid,
                    module: Mockatron.Responder.Sequential
                  })
              })
            )

          _ ->
            conn
        end

      nil ->
        conn
    end
  end
end
