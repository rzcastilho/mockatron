defmodule Plug.Parsers.XML do

  @behaviour Plug.Parsers

  def init(opts), do: opts

  def parse(conn, _, "xml", _headers, opts) do
    {decoder, opts} = Keyword.pop(opts, :xml_decoder)
    {{mod, fun, args}, opts} = Keyword.pop(opts, :body_reader)
    apply(mod, fun, [conn, opts | args]) |> decode(decoder)
  end

  def parse(conn, _, "soap+xml", _headers, opts) do
    {decoder, opts} = Keyword.pop(opts, :xml_decoder)
    {{mod, fun, args}, opts} = Keyword.pop(opts, :body_reader)
    apply(mod, fun, [conn, opts | args]) |> decode(decoder)
  end

  def parse(conn, _type, _subtype, _headers, _opts) do
    {:next, conn}
  end

  defp decode({:ok, body, conn}, decoder) do
    case decoder.string(String.to_charlist(body)) do
      {parsed, []} ->
        {:ok, %{xml: parsed}, conn}
      error ->
        raise "Malformed XML #{error}"
    end
  rescue
    e -> raise Plug.Parsers.ParseError, exception: e
  end

end
