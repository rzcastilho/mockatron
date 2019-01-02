defmodule MockatronWeb.FindCache do
  import Plug.Conn

  def init(opts) do
    Keyword.fetch!(opts, :cache)
  end

  def call(%Plug.Conn{assigns: %{mockatron: %{agent: %{hash: hash} = agent} = mockatron}} = conn, :agent = cache) do
    get_from_cache(conn, mockatron, agent, hash, cache)
  end

  def call(%Plug.Conn{assigns: %{mockatron: %{responder: %{hash: hash} = responder} = mockatron}} = conn, :responder = cache) do
    get_from_cache(conn, mockatron, responder, hash, cache)
  end

  defp get_from_cache(conn, mockatron, item, hash, cache) do
    case Cachex.get(cache, hash) do
      {:ok, nil} ->
        conn
      {:ok, from_cache} ->
        conn
        |> assign(:mockatron, Map.merge(mockatron, %{cache => Map.merge(%{item|cache: true, found: true}, from_cache)}))
    end
  end

end
