port module MicroElm.Playground exposing (base)

import Peg
import UniversalEncoder.Base64
import UniversalEncoder.Encode
import Wasm.Encode
import Wasm.Module


port sendMessage : String -> Cmd msg


port sendError : String -> Cmd msg


port messageReceiver : (( String, String ) -> msg) -> Sub msg


type alias State a =
    { a | wasm : Wasm.Module.Module }


base : State a -> Peg.Actions (State a) -> Program () () ( String, String )
base empty aaa =
    Platform.worker
        { init = \_ -> ( (), Cmd.none )
        , update = \msg _ -> update empty aaa msg
        , subscriptions = \_ -> messageReceiver identity
        }


update empty actions ( grammarStr, code ) =
    let
        result =
            grammarStr
                |> Peg.fromString
                --|> Result.mapError (Debug.log "GOT ERROR")
                |> Result.andThen (doWork empty actions code)
    in
    case result of
        Ok output ->
            ( (), sendMessage output )

        Err err ->
            let
                output =
                    String.fromInt err.position
                        |> (++) " :"
                        |> (++) err.message
            in
            ( (), sendError output )


doWork empty actions code grammar =
    Peg.parse grammar empty actions (\_ _ state -> ( True, state )) code
        |> Result.map .wasm
        |> Result.map encodeWasm


encodeWasm mod =
    let
        _ =
            mod
                |> Wasm.Encode.text

        --|> Debug.log ""
    in
    mod
        |> Wasm.Encode.binary
            { initialState = []
            , addByte = \i state -> UniversalEncoder.Encode.unsignedInt8 i :: state
            }
        |> List.reverse
        |> UniversalEncoder.Encode.sequence
        |> UniversalEncoder.Base64.encode
