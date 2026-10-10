defmodule Example3 do
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
    id_some_node
  end

  def foo_node() do
    # process
  end

  def graph() do
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
    choose_route(state)
  end

  def graph(start) do
    start
    |> node(:foo_1, &foo_node_1/1)
    |> node(:foo_2, &foo_node_2/1)
    |> node(:decision, &decision_node/1)
    <~> [
      first:  {&foo_node_3/1, next: :foo_1},
      second: {&foo_node_4/1, next: :decision},
      third:  {&foo_node_5/1, next: :foo_2},
      fourth: {&foo_node_6/1, next: :exit}
    ]
    |> node(:foo_7, &foo_node_7/1)
  end
end
