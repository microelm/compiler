port module MainWasm exposing (..)

import UniversalEncoder.Base64
import UniversalEncoder.Encode
import Wasm.Encode
import Wasm.Instruction
import Wasm.Module exposing (Module)
import Wasm.Type


port sendMessage : String -> Cmd msg


main : Program () {} msg
main =
    Platform.worker
        { init = init
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


helloWorld2 : Module
helloWorld2 =
    { functions =
        [ Wasm.Module.FunctionDefined
            { name = "hello"
            , params = []
            , results = [ Wasm.Type.I32 ]
            , locals = []
            , exported = True
            , body =
                [ Wasm.Instruction.I32Const 1
                , Wasm.Instruction.I32Const 2
                , Wasm.Instruction.I32Add
                , Wasm.Instruction.Return
                ]
            }
        ]
    , globals = []
    , tables = []
    , memories = []
    }


helloWorld : Module
helloWorld =
    { functions =
        [ Wasm.Module.FunctionDefined
            { name = "hello"
            , params = [ Wasm.Type.I64, Wasm.Type.I64 ]
            , results = [ Wasm.Type.I64 ]
            , locals = []
            , exported = True
            , body =
                [ Wasm.Instruction.LocalGet 0
                , Wasm.Instruction.LocalGet 1
                , Wasm.Instruction.I64Add
                ]
            }
        ]
    , globals = []
    , tables = []
    , memories = []
    }


init _ =
    let
        _ =
            helloWorld
                |> Wasm.Encode.text
                |> Debug.log "WAT"

        wasmBase64 =
            helloWorld
                |> Wasm.Encode.binary
                    { initialState = []
                    , addByte = \i state -> UniversalEncoder.Encode.unsignedInt8 i :: state
                    }
                |> List.reverse
                |> UniversalEncoder.Encode.sequence
                |> UniversalEncoder.Base64.encode
                |> Debug.log "WASM"
    in
    ( {}, sendMessage wasmBase64 )
