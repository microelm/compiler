port module MicroElm.V001 exposing (..)

import MicroElm.Playground
import Wasm.Instruction
import Wasm.Module
import Wasm.Type


port sendMessage : String -> Cmd msg


port sendError : String -> Cmd msg


main =
    MicroElm.Playground.base empty actions


type alias State =
    { wasm : Wasm.Module.Module
    , fnName : String
    , fnValue : String
    }


empty : State
empty =
    { wasm = emptyModule
    , fnName = ""
    , fnValue = ""
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

        "FunctionReturn" ->
            let
                wasm =
                    state.wasm

                vvv =
                    String.toInt value |> Maybe.withDefault 0
            in
            Ok
                { state
                    | fnValue = value
                    , wasm =
                        { wasm
                            | functions =
                                wasm.functions
                                    ++ [ Wasm.Module.FunctionDefined
                                            { name = state.fnName
                                            , params = []
                                            , results = [ Wasm.Type.I32 ]
                                            , locals = []
                                            , exported = True
                                            , body =
                                                [ Wasm.Instruction.I32Const vvv
                                                ]
                                            }
                                       ]
                        }
                }

        _ ->
            Err "Not Implemented"
