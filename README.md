# From pipes to graphs

Could Elixir's pipe model grow naturally from chains into graphs, while keeping
the simplicity that makes it useful?

A pipe makes a sequence easy to read: take a value, transform it, pass it on.
An AI agent often needs another shape: make a decision, call a tool, return to
the decision, and eventually produce a reply. This project explores syntax that
could make those branches and cycles visible in the flow itself.

The motivation comes from graph-based agent workflows such as those associated
with LangGraph. The proposal is narrow: explore how to express routing and
revisiting steps through a familiar pipe-shaped composition.

## Start with a working branch

The prototype can already express this in Elixir, using operators defined in
this repository:

```elixir
start
|> llm(tools)
<~> [fn args -> use_tool(args, tools) end, &reply/1]
```

The decision returned by `llm/2` selects one function and supplies its input.
In this example, `llm/2` is a random stub, so no model or external service is
needed.

- `|>` keeps its usual role: pass the result into the next call.
- `nil <~ payload` tags the first alternative, here a tool call.
- `nil ~> payload` tags the second alternative, here a reply.
- `<~>` runs the selected branch and returns its result.

The `nil` operand is a placeholder in this prototype. The markers do not jump
backward or forward by themselves, and the branches do not run in parallel.
An explicit recursive function still sends tool results back to the decision.

## The next step: make the cycle visible

What if steps had names, and a branch could say where execution should resume?
This is **proposed pseudocode**, not a working API:

```elixir
start
|> node(:decision, &decide/1)
<~> [
  tool: {&use_tool/1, next: :decision},
  done: {&prepare_reply/1, next: :exit}
]
|> node(:reply, &reply/1)
```

The tool route would run its function and revisit `:decision`. The done route
would run its function, leave the cycle through `:exit`, and continue at
`:reply`. Here, `:exit` means leaving the cycle, not terminating the whole graph.

That is the central idea: preserve the readable sequence while making choices
and return paths part of its structure. The exact syntax, decision payload
contract, and traversal rules remain open for discussion.

## Read the examples

- [Working examples](lib/example/example.ex): `Example1` uses ordinary pipes
  and explicit routing; `Example2` expresses the same flow with operators.
- [Operator implementation](lib/graph.ex): the small routing prototype behind
  the working examples.
- [Design sketches](pseudo_code/example.ex): `Example3` explores two paths,
  `Example4` expands the destinations, and `Example5` makes node names explicit.

The repository does not modify Elixir or implement a full LangGraph-style
runtime. Named-node traversal, persistence, parallel execution, and other runtime
capabilities are outside this prototype.

## An invitation to discuss

Elixir already offers functions, pattern matching, and recursion for expressing
these flows. The question is whether a small extension to pipe composition
could make them easier to read as AI workflows become more common.

Would this keep the pipe simple? Are the branch and cycle boundaries clear?
Should this remain a library experiment, or is there a small idea here worth
considering for the language?

