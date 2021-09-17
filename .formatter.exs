locals_without_parens = [rpc: 1, rpc: 2]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  import_deps: [:xema],
  export: [
    locals_without_parens: locals_without_parens
  ]
]
