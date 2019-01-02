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
    %{id: agent.id,
      method: agent.method,
      protocol: agent.protocol,
      host: agent.host,
      port: agent.port,
      path: agent.path,
      content_type: agent.content_type,
      responder: agent.responder,
      operation: agent.operation
    }
  end
end
