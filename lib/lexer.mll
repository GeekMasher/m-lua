{
open Parser
}

let white = [' ' '\t' '\n']+
let digit = ['0'-'9']
let float = '-'? digit+ ("." digit+)?
let letter = ['a'-'z' 'A'-'Z' '_']
let id = letter (letter | digit)*

(* Need to handle [==[ string inside ]==], this kind of stuff *)
let str1 = '\"' ([^ '\"' '\\' ] | ([ '\\' ] [^ '_' ]))* '\"'
let str2 = '\'' ([^ '\'' '\\' ] | ([ '\\' ] [^ '_' ]))* '\''
let string = str1 | str2
let lstr = '[' '='* '['
let lcomm = '-' '-' lstr
let lend = ']' '='*

let tr_ellipsis = ',' white '.' '.' '.'

rule read =
  parse
  | white { read lexbuf }
  | "--" [^ '\n']* { read lexbuf }
  | "nil" { NIL }
  | "true" { TRUE }
  | "false" { FALSE }
  | "(" { LPAR }
  | ")" { RPAR }
  | "[" { LBRACKET }
  | "]" { RBRACKET }
  | "{" { LBRACE }
  | "}" { RBRACE }
  | "," { COMMA }
  | ";" { SEMICOLON }
  | ".." { CONCAT }
  | "." { DOT }
  | "#" { OCTOTHORPE }
  | ":" { COLON }
  | "=" { EQUAL }
  | "+" { PLUS }
  | "-" { MINUS }
  | "*" { STAR }
  | "/" { SLASH }
  | "^" { EXP }
  | "%" { MOD }
  | "<" { LT }
  | "<=" { LTE }
  | ">" { GT }
  | ">=" { GTE }
  | "==" { EQ }
  | "~=" { NEQ }
  | "and" { AND }
  | "or" { OR }
  | "not" { NOT }
  | "local" { LOCAL }
  | "return" { RETURN }
  | "break" { BREAK }
  | "function" { FUNCTION }
  | "end" { END }
  | "for" { FOR }
  | "while" { WHILE }
  | "repeat" { REPEAT }
  | "then" { THEN }
  | "if" { IF }
  | "else" { ELSE }
  | "elseif" { ELSEIF }
  | "in" { IN }
  | "until" { UNTIL }
  | "do" { DO }
  | tr_ellipsis { TR_ELLIPSIS }
  | "..." { ELLIPSIS }
  | float { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  | string { 
      let quoted_string = Lexing.lexeme lexbuf in
      STRING (String.sub quoted_string 1 (String.length quoted_string - 2))
    }
  | id { NAME (Name.of_string (Lexing.lexeme lexbuf)) }
  | eof { EOF }
