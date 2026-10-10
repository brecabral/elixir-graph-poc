# Design sketches only: these examples are not executable Elixir.
# Node functions, route values, and graph traversal are illustrative placeholders.
defmodule Example3 do
  # Explore prefix markers for choosing a return path or a forward path.
  # Unlike the working binary operators, this prefix notation is only proposed.
  def decision_node() do
    if decide do
      <~ return_node
    else
      ~> follow_node
    end
  end

  def foo_node() do
    # process
  end

  def graph() do
    # The former route revisits foo_node_1 after running its branch.
    # The latter route continues through fool_node_3 to the remaining pipe.
    start
    |> foo_node_1
    |> decision_node_1
    <~> [
      former: {fool_node_2, goto_foo_node_1},
      latter: {fool_node_3}
    ]
    |> fool_node_4
  end
end

defmodule Example4 do
  def decision_node() do
    # Explore a node identifier as the decision, allowing more than two routes.
    id_some_node
  end

  def foo_node() do
    # process
  end

  def graph() do
    # Each entry sketches a branch and its destination, including earlier nodes.
    # The identifier-to-entry mapping remains an open part of this sketch.
    # :exit is intended to leave the cycle and continue at fool_node_7.
    start
    |> foo_node_1
    |> foo_node_2
    |> decision_node_1
    <~> [
      {fool_node_3, goto_foo_node_1},
      {fool_node_4, decision_node_1},
      {fool_node_5, goto_foo_node_2},
      {fool_node_6, :exit},
    ]
    |> fool_node_7
  end
end

defmodule Example5 do
  def decision_node(state) do
    # Choose a named route from the current state; the payload contract is open.
    choose_route(state)
  end

  def graph(start) do
    # Proposed node/2 labels make destinations explicit within the pipe.
    # This helper and the next: traversal behavior are not implemented.
    start
    |> node(:foo_1, &foo_node_1/1)
    |> node(:foo_2, &foo_node_2/1)
    |> node(:decision, &decision_node/1)
    # Run the selected branch, then resume at its named destination.
    <~> [
      first:  {&foo_node_3/1, next: :foo_1},
      second: {&foo_node_4/1, next: :decision},
      third:  {&foo_node_5/1, next: :foo_2},
      # Leave the cycle after foo_node_6 and continue at foo_7 below.
      fourth: {&foo_node_6/1, next: :exit}
    ]
    |> node(:foo_7, &foo_node_7/1)
  end
end
