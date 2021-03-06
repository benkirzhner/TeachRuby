type token =
  | EOF
  | TIMES
  | PLUS
  | INT of (int)

module Dyp_priority_data :
sig
  val priority_data : Dyp.priority_data
  val default_priority : Dyp.priority
end

val main : (Lexing.lexbuf -> token) -> Lexing.lexbuf -> ((Parse_tree.tree) * Dyp.priority) list

