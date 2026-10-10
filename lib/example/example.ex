defmodule Example1 do
  # Baseline: ordinary pipes plus explicit route selection and recursion.
  def example_tool(param) do
    IO.puts(param)
    "Tool Result"
  end

  def tools_list, do: [example_tool: &example_tool/1]

  def llm(msg, _tools) do
    # Simulate an LLM choosing a tool call or a final reply; no model is called.
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
    # The decision carries both the route name and the selected branch's input.
    result =
      start
      |> llm(tools)
      |> Graph.chooses(
        first: fn args -> use_tool(args, tools) end,
        second: &reply/1
      )

    # A tool result becomes the next input; a reply ends the recursive loop.
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
  # The same flow, with imported operators expressing the two-way choice.
  use Graph

  def example_tool(param) do
    IO.puts(param)
    "Tool Result"
  end

  def tools_list, do: [example_tool: &example_tool/1]

  def llm(msg, _tools) do
    # Random selection stands in for a model decision.
    # <~ selects the former branch (tool); ~> selects the latter (reply).
    # nil is only the unused left operand required by these binary operators.
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
    # <~> runs one branch with the decision payload, not both in parallel.
    result =
      start
      |> llm(tools)
      <~> [fn args -> use_tool(args, tools) end, &reply/1]

    # The operators handle branching; recursion still implements the cycle.
    case result do
      :end_loop -> :ok
      value -> agent_loop(value, tools)
    end
  end

  def basic_agent(start, tools \\ nil) do
    agent_loop(start, tools || tools_list())
  end
end
