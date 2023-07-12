port module Main exposing (..)


port sendMessage : String -> Cmd msg


main : Program () {} msg
main =
    Platform.worker
        { init = \_ -> ( {}, sendMessage "hello world" )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
