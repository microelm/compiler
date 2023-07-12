module MainBase64 exposing (main)

import UniversalEncoder.Base64
import UniversalEncoder.Encode exposing (Encoder(..))


main : Program () {} msg
main =
    Platform.worker
        { init = init
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


init _ =
    let
        initState =
            { encoded = ""
            , leftOver = 0
            , encodedLength = 0
            }

        intToBinaryString : Int -> String
        intToBinaryString int_ =
            let
                binary : Int -> List Char -> List Char
                binary int acc =
                    if int == 0 then
                        acc

                    else
                        let
                            nextBit =
                                if modBy 2 int == 1 then
                                    '1'

                                else
                                    '0'
                        in
                        binary (int // 2) (nextBit :: acc)
            in
            String.padLeft 8 '0' (binary int_ [] |> String.fromList)

        encoder =
            Sequence
                [ Bit False
                , Bit False
                , Bit False
                , Bit False
                , Bit False
                , Byte 120
                , Bit False
                , Bit False
                , Bit False
                , Bit True
                ]

        convert byte state =
            state ++ " " ++ intToBinaryString byte

        _ =
            UniversalEncoder.Encode.encode convert "" encoder
                |> Debug.log "Bits"

        _ =
            UniversalEncoder.Base64.encode encoder
                |> Debug.log "Base64"
    in
    ( {}, Cmd.none )
