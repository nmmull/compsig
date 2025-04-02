let () = print_endline "Hello, World!"

let int_to_exponent (x : int) : string =
  let rec go output_string = function
    | 0 -> output_string
    | num -> 
      let take_value value =
        let ones = value mod 10 in
        let other = value - ones in
        let find_exp n = 
          match n with
          | 0 -> "⁰"
          | 1 -> "¹"
          | 2 -> "²"
          | 3 -> "³"
          | 4 -> "⁴"
          | 5 -> "⁵"
          | 6 -> "⁶"
          | 7 -> "⁷"
          | 8 -> "⁸"
          | 9 -> "⁹"
          | _ -> assert false
        in
        find_exp ones, other
      in
      match take_value num with
      | (expon, other) -> go (expon ^ output_string) (other / 10)
  in
  go "" x

let () = print_endline (int_to_exponent 125684)