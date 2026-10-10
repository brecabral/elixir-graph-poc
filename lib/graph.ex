defmodule Graph do
  defmacro __using__(_opts) do
    quote do
      import Graph
    end
  end

  def choice(key, args), do: {key, args}

  def chooses({key, args}, functions) do
    functions
    |> Keyword.fetch!(key)
    |> then(& &1.(args))
  end

  def _left <~ args, do: choice(:former, args)
  def _left ~> args, do: choice(:latter, args)

  def {key, args} <~> [former, latter] do
    case key do
      :former -> former.(args)
      :latter -> latter.(args)
    end
  end
end
