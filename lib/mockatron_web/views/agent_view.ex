defmodule MockatronWeb.AgentView do
  use MockatronWeb, :view
  alias MockatronWeb.AgentView

  def render("index.json", %{agents: agents}) do
    %{data: render_many(agents, AgentView, "agent.json")}
  end

  def render("show.json", %{agent: agent}) do
    %{data: render_one(agent, AgentView, "agent.json")}
  end

  def render("agent.json", %{agent: agent}) do
    %{
      id: agent.id,
      content_type: agent.content_type,
      host: agent.host,
      method: agent.method,
      path: agent.path,
      path_regex: agent.path_regex,
      port: agent.port,
      protocol: agent.protocol,
      responder: agent.responder,
      operation: agent.operation
    }
  end
end
