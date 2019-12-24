defmodule Mockatron.Responder.RandomTest do
  use ExUnit.Case

  @sequential_responses [
    %{"code" => "0", "description" => "Success"},
    %{"code" => "1", "description" => "Technical Error"},
    %{"code" => "2", "description" => "Business Error"},
    %{"code" => "0", "description" => "Success"},
    %{"code" => "1", "description" => "Technical Error"},
    %{"code" => "2", "description" => "Business Error"}
  ]

  @agent %Mockatron.Core.Agent{
    content_type: "application/json",
    host: "localhost",
    id: 1,
    inserted_at: ~N[2018-10-08 21:30:10.630312],
    method: "GET",
    path: "/posts",
    port: 80,
    protocol: "http",
    responder: "round_robin",
    responses: [
      %Mockatron.Core.Response{
        agent_id: 1,
        body: "{\"code\":\"0\",\"description\":\"Success\"}",
        enable: true,
        http_code: 200,
        id: 4,
        inserted_at: ~N[2018-10-19 20:08:17.673978],
        label: "Success",
        updated_at: ~N[2018-10-19 20:08:17.673986]
      },
      %Mockatron.Core.Response{
        agent_id: 1,
        body: "{\"code\":\"1\",\"description\":\"Technical Error\"}",
        enable: true,
        http_code: 200,
        id: 3,
        inserted_at: ~N[2018-10-19 20:08:16.984550],
        label: "Success",
        updated_at: ~N[2018-10-19 20:08:16.984560]
      },
      %Mockatron.Core.Response{
        agent_id: 1,
        body: "{\"code\":\"2\",\"description\":\"Business Error\"}",
        enable: true,
        http_code: 200,
        id: 2,
        inserted_at: ~N[2018-10-19 20:08:14.406840],
        label: "Success",
        updated_at: ~N[2018-10-19 20:08:14.409722]
      }
    ],
    updated_at: ~N[2018-10-08 21:30:10.634831]
  }

  setup do
    {:ok, pid} = Mockatron.Responder.Random.start_link(@agent)
    {:ok, server: pid}
  end

  test "get random responses", %{server: pid} do
    current_random_responses = 1..6
    |> Enum.map(
         fn _ ->
           %{body: body} = Mockatron.Responder.Random.response(pid, nil);
           Jason.decode!(body);
         end)
    assert @sequential_responses != current_random_responses
  end

  test "get random state", %{server: pid} do
    assert %Mockatron.Responder.Random.State{agent: agent, size: size, index: index, count: count} =
             Mockatron.Responder.Random.state(pid)
  end

end
