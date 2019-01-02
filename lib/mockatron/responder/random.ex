defmodule Mockatron.Responder.Random do
  use GenServer

  defmodule State do
    defstruct [agent: nil, size: nil, index: 0, count: 0]
  end

  def start_link(%Mockatron.Core.Agent{} = agent) do
    GenServer.start_link(__MODULE__, %State{agent: agent, size: length(agent.responses)}, [])
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  def response(pid, _conn) do
    GenServer.call(pid, :response)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call(:state, _from, state) do
    { :reply, state, state }
  end

  def handle_call(:response, _from, %State{agent: agent, size: size, count: count} = state) do
    index = Enum.random(0..size-1)
    { :reply, Enum.at(agent.responses, index), %State{state|index: index, count: count+1 } }
  end

end