defmodule Mockatron.AgentResponder do
  defmodule Signature do
    defstruct user_id: nil,
              method: nil,
              protocol: nil,
              host: nil,
              port: nil,
              path: nil,
              operation: :none,
              content_type: :none
  end

  defmodule Agent do
    defstruct hash: false, cache: false, found: false, agent: nil
  end

  defmodule Responder do
    defstruct hash: false, cache: false, found: false, filter: nil, pid: nil, module: nil
  end

  defstruct signature: Signature.__struct__(),
            agent: Agent.__struct__(),
            responder: Responder.__struct__()
end
