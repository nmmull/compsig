let () =
  let input = In_channel.(input_all stdin) in
  print_string (Compsig.(convert LambdaSC Supercollider input))
