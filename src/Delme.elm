module Delme exposing (..)

import Html as HTMl
import Peg exposing (Error, fromString, parse)


grammarString : String
grammarString =
    """
Expr         <- Term (AddOp Term)* {expr}
Term         <- Factor (MulOp Factor)* {term}
Factor       <- <'(' Expr ')'>{factor} / <Number>{factor} / <Variable> {factor}
Number       <- <[0-9]+> {number}
Variable     <- <[a-zA-Z]+> {variable}
AddOp        <- <'+'>{plus} / <'-'>{minus}
MulOp        <- <'*'>{times} / <'/'> {div}
    """


actions name str state =
    let
        _ =
            Debug.log "action:" ( name, str )
    in
    case name of
        "number" ->
            Ok str

        "variable" ->
            Ok str

        "term" ->
            Ok str

        "factor" ->
            Ok str

        "expr" ->
            Ok str

        "addOp" ->
            Ok str

        "mulOp" ->
            Ok str

        "plus" ->
            Ok str

        "minus" ->
            Ok str

        "times" ->
            Ok str

        "div" ->
            Ok str

        _ ->
            Err ("unknown action: \"" ++ name ++ "\"")


predicate _ _ state =
    ( True, state )


compile : String -> Result Error String
compile input =
    grammarString
        |> fromString
        |> Result.andThen (\grammar -> parse grammar "" actions predicate input)


{-| Check if the parse succeeded
-}
main =
    let
        _ =
            compile "(1+2)*3" |> Debug.log "1:"

        --_ =
        --    compile "x+y*z" |> Debug.log "2:"
        --
        --_ =
        --    compile "1+" |> Debug.log "3:"
    in
    HTMl.text "DONE"
