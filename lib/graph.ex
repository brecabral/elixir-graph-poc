defmodule Graph do
  # Import the prototype operators into the calling module.
  defmacro __using__(_opts) do
    quote do
      import Graph
    end
  end

  # Keep the route and its payload together until a branch is selected.
  def choice(key, args), do: {key, args}

  def chooses({key, args}, functions) do
    # Call only the function registered for this route, passing it the payload.
    functions
    |> Keyword.fetch!(key)
    |> then(& &1.(args))
  end

  # These operators tag alternatives; they do not jump to another node.
  # The left operand is unused (the examples use nil as a placeholder).
  def _left <~ args, do: choice(:former, args)
  def _left ~> args, do: choice(:latter, args)

  def {key, args} <~> [former, latter] do
    # Dispatch to one of two branches and return its result to the caller.
    case key do
      :former -> former.(args)
      :latter -> latter.(args)
    end
  end
end
