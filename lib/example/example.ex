defmodule Example1 do
  def example_tool(param) do
    IO.puts(param)
    "Tool Result"
  end

  def tools_list, do: [example_tool: &example_tool/1]

  def llm(msg, _tools) do
    if Enum.random(1..10) < 5 do
      Graph.choice(:first, %{tool: :example_tool, param: "Using Tool"})
    else
      Graph.choice(:second, msg)
    end
  end

  def use_tool(%{tool: tool_name, param: param}, tools) do
    Keyword.fetch!(tools, tool_name).(param)
  end

  def reply(msg) do
    IO.puts("Exit: #{msg}")
    :end_loop
  end

  def agent_loop(start, tools) do
    result =
      start
      |> llm(tools)
      |> Graph.chooses(
        first: fn args -> use_tool(args, tools) end,
        second: &reply/1
      )

    case result do
      :end_loop -> :ok
      value -> agent_loop(value, tools)
    end
  end

  def basic_agent(start, tools \\ nil) do
    agent_loop(start, tools || tools_list())
  end
end

defmodule Example2 do
  use Graph

  def example_tool(param) do
    IO.puts(param)
    "Tool Result"
  end

  def tools_list, do: [example_tool: &example_tool/1]

  def llm(msg, _tools) do
    if Enum.random(1..10) < 5 do
      nil <~ %{tool: :example_tool, param: "Using Tool"}
    else
      nil ~> msg
    end
  end

  def use_tool(%{tool: tool_name, param: param}, tools) do
    Keyword.fetch!(tools, tool_name).(param)
  end

  def reply(msg) do
    IO.puts("Exit: #{msg}")
    :end_loop
  end

  def agent_loop(start, tools) do
    result =
      start
      |> llm(tools)
      <~> [fn args -> use_tool(args, tools) end, &reply/1]

    case result do
      :end_loop -> :ok
      value -> agent_loop(value, tools)
    end
  end

  def basic_agent(start, tools \\ nil) do
    agent_loop(start, tools || tools_list())
  end
end
