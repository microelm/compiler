module MainPEG exposing (main)

import Dict
import Peg exposing (Grammar)
import Peg.Test


input2 =
    """   aaa          <-  <!(world) "hello"> {test}   """


defaultInput =
    """
   Grammar         <- Spacing Definition+ EndOfFile
   Definition      <- Identifier {RuleName} LEFTARROW Expression {AddGrammar}
   Expression      <- {ChoiceStart} Sequence {AddRule} (SLASH Sequence {AddRule})* {ChoiceEnd}
   Sequence        <- {SequenceStart} (Prefix {AddRule})* {SequenceEnd}
   Prefix          <- AND Action {SetConditionalPredicate}
                   #/ ( AND / NOT )? Suffix
                   / {PositiveLookaheadStart} AND Suffix {AddRule} {PositiveLookaheadEnd}
                   / {NegativeLookaheadStart} NOT Suffix {AddRule} {NegativeLookaheadEnd}
                   / Suffix
   Suffix         <- Primary ( (QUERY {SetOptional}) / (STAR {SetZeroOrMore}) / (PLUS {SetOneOrMore}) )?
   Primary        <- Identifier !LEFTARROW {SetRuleRef}
                   / OPEN Expression CLOSE
                   / Literal {SetMatchLiteral}
                   / Class {SetRange}
                   / DOT {SetMatchAny}
                   / Action {SetAction}
                   / BEGIN {CollectStart}
                   / END {CollectEnd}
   Identifier      <- < IdentStart IdentCont* > Spacing
   IdentStart      <- [a-zA-Z_]
   IdentCont       <- IdentStart / [0-9]
   Literal         <- ['] < ( !['] Char  )* > ['] Spacing
                   / ["] < ( !["] Char  )* > ["] Spacing
   Class           <- '[' < ( !']' Range )* > ']' Spacing
   Range           <- Char '-' Char / Char
   Char            <- '\\\\' [abefnrtv'"\\[\\]\\\\]
                   / '\\\\' [0-3][0-7][0-7]
                   / '\\\\' [0-7][0-7]?
                   / '\\\\' '-'
                   / !'\\\\' .
   LEFTARROW       <- '<-' Spacing
   SLASH           <- '/' Spacing
   AND             <- '&' Spacing
   NOT             <- '!' Spacing
   QUERY           <- '?' Spacing
   STAR            <- '*' Spacing
   PLUS            <- '+' Spacing
   OPEN            <- '(' Spacing
   CLOSE           <- ')' Spacing
   DOT             <- '.' Spacing
   Spacing         <- ( Space / Comment )*
   Comment         <- '#' ( !EndOfLine . )* EndOfLine

   Space           <- ' ' / '\t' / (EndOfLine) # TODO find why it must be wrapped in brackets
   """
        ++ "EndOfLine       <- '\u{000D}\n' / '\n' / '\u{000D}'"
        ++ """EndOfFile       <- !.
   Action          <- '{' < [^}]* > '}' Spacing
   BEGIN           <- '<' Spacing
   END             <- '>' Spacing
   """


main : Program String {} msg
main =
    Platform.worker
        { init = init
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


init flags =
    let
        inputGrammar =
            if flags /= "" then
                flags

            else
                defaultInput

        parseResult =
            inputGrammar
                |> Peg.fromString
                |> Result.mapError (Debug.log "GOT ERROR")

        _ =
            parseResult
                |> Result.map (Debug.log "first pass")
                |> Result.map
                    (\i ->
                        let
                            _ =
                                doTest i
                        in
                        i
                    )
                |> Result.andThen
                    (\aaa ->
                        Peg.parse aaa Peg.PegInPeg.initialState Peg.PegInPeg.actions Dict.empty inputGrammar
                    )
                |> Result.map (Debug.log "second pass")
                |> Result.mapError (Debug.log "second passFail")
    in
    ( {}, Cmd.none )


doTest gg =
    List.map2
        (\( name, a ) ( name2, b ) ->
            Peg.Test.compareRules a b |> Debug.log (name ++ ":" ++ name2)
        )
        Peg.PegInPeg.grammar
        gg
