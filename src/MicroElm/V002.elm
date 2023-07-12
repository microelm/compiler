port module MicroElm.V002 exposing (..)

import Dict exposing (Dict)
import MicroElm.Playground
import Wasm.Instruction
import Wasm.Module
import Wasm.Type


port sendMessage : String -> Cmd msg


port sendError : String -> Cmd msg


main =
    MicroElm.Playground.base empty actions


type ArgValue
    = ArgValueRef String
    | ArgValueLiteral String


type alias State =
    { wasm : Wasm.Module.Module
    , fnIndexes : Dict String Int
    , fnName : String
    , fnValue : String
    , fnNativeCall : Wasm.Instruction.Instruction
    , fnNativeCallArg1 : ArgValue
    , fnNativeCallArg2 : ArgValue
    , argValue : ArgValue
    }


empty : State
empty =
    { wasm = emptyModule
    , fnIndexes = Dict.empty
    , fnName = ""
    , fnValue = ""
    , fnNativeCall = Wasm.Instruction.Nop
    , fnNativeCallArg1 = ArgValueLiteral ""
    , fnNativeCallArg2 = ArgValueLiteral ""
    , argValue = ArgValueLiteral ""
    }


emptyModule =
    { functions = []
    , globals = []
    , tables = []
    , memories = []
    }


actions name value state =
    case name of
        "FunctionName" ->
            Ok { state | fnName = value }

        "RULE_Call_Start" ->
            let
                _ =
                    Debug.log "RULE_Call_Start" value
            in
            Ok state

        "RULE_Call_End" ->
            let
                args =
                    argValueToArg state.fnNativeCallArg1 state.fnIndexes
                        |> Result.andThen
                            (\a1 ->
                                argValueToArg state.fnNativeCallArg2 state.fnIndexes
                                    |> Result.map (\b -> ( a1, b ))
                            )
            in
            case args of
                Err err ->
                    Err err

                Ok ( arg1, arg2 ) ->
                    let
                        wasm =
                            state.wasm

                        newFn =
                            Wasm.Module.FunctionDefined
                                { name = state.fnName
                                , params = []
                                , results = [ Wasm.Type.I64 ]
                                , locals = []
                                , exported = True
                                , body =
                                    [ arg1
                                    , arg2
                                    , state.fnNativeCall
                                    ]
                                }
                    in
                    { state
                        | fnValue = value
                        , wasm = { wasm | functions = wasm.functions ++ [ newFn ] }
                    }
                        |> indexFunctionName
                        |> Ok

        "RULE_NativeFunctionName" ->
            let
                _ =
                    Debug.log "RULE_NativeFunctionName" value
            in
            case value of
                "(+)" ->
                    Ok { state | fnNativeCall = Wasm.Instruction.I64Add }

                "(-)" ->
                    Ok { state | fnNativeCall = Wasm.Instruction.I64Sub }

                "(^)" ->
                    Err "function \"Power(^)\" is not yet implemented"

                "(*)" ->
                    Ok { state | fnNativeCall = Wasm.Instruction.I64Mul }

                "(/)" ->
                    Ok { state | fnNativeCall = Wasm.Instruction.I64DivS }

                "(//)" ->
                    Ok { state | fnNativeCall = Wasm.Instruction.I64DivS }

                "remainderBy" ->
                    Ok { state | fnNativeCall = Wasm.Instruction.I64RemS }

                _ ->
                    Err ("unknown function" ++ value)

        --Ok state
        "RULE_Arg1" ->
            let
                _ =
                    Debug.log "RULE_Arg1" state.argValue
            in
            Ok { state | fnNativeCallArg1 = state.argValue }

        "RULE_Arg2" ->
            let
                _ =
                    Debug.log "RULE_Arg2" state.argValue
            in
            Ok { state | fnNativeCallArg2 = state.argValue }

        "FunctionReturn" ->
            let
                wasm =
                    state.wasm

                vvv =
                    String.toInt value |> Maybe.withDefault 0
            in
            { state
                | fnValue = value
                , wasm =
                    { wasm
                        | functions =
                            wasm.functions
                                ++ [ Wasm.Module.FunctionDefined
                                        { name = state.fnName
                                        , params = []
                                        , results = [ Wasm.Type.I64 ]
                                        , locals = []
                                        , exported = True
                                        , body =
                                            [ Wasm.Instruction.I64Const vvv
                                            ]
                                        }
                                   ]
                    }
            }
                |> indexFunctionName
                |> Ok

        "RULE_ArgLiteral" ->
            Ok { state | argValue = ArgValueLiteral value }

        "RULE_ArgRef" ->
            Ok { state | argValue = ArgValueRef value }

        _ ->
            Err "Not Implemented"


argValueToArg arg indexes =
    case arg of
        ArgValueRef ref ->
            case Dict.get ref indexes of
                Nothing ->
                    ("function \"" ++ ref ++ "\" should be defined before use (TODO)")
                        |> Err

                Just v ->
                    v
                        |> Wasm.Instruction.Call
                        |> Ok

        ArgValueLiteral v ->
            stringToI64Const v
                |> Ok


stringToI64Const str =
    String.toInt str
        |> Maybe.withDefault 0
        |> Wasm.Instruction.I64Const


indexFunctionName state =
    { state | fnIndexes = Dict.insert state.fnName (Dict.size state.fnIndexes) state.fnIndexes }
