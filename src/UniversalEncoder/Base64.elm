module UniversalEncoder.Base64 exposing (encode)

import Bitwise
import UniversalEncoder.Encode exposing (Encoder(..))


encode : Encoder -> String
encode =
    UniversalEncoder.Encode.encode encodeByte { encoded = "", leftOver = 0, encodedLength = 0 } >> finish


type alias Base64State =
    { encoded : String
    , leftOver : Int
    , encodedLength : Int
    }


encodeByte : Int -> Base64State -> Base64State
encodeByte n state =
    let
        toString input =
            Bitwise.and input 63
                |> base64Char
                |> String.fromChar
    in
    case Bitwise.shiftRightBy 4 state.leftOver of
        0 ->
            let
                input =
                    Bitwise.and n 252
                        |> Bitwise.shiftRightBy 2
            in
            { encoded =
                state.encoded ++ toString input
            , leftOver = Bitwise.and n 3 + 16
            , encodedLength = state.encodedLength + 1
            }

        1 ->
            let
                input =
                    Bitwise.and state.leftOver 3
                        |> Bitwise.shiftLeftBy 4
                        |> (+) (Bitwise.and n 240 |> Bitwise.shiftRightBy 4)
            in
            { encoded = state.encoded ++ toString input
            , leftOver = Bitwise.and n 15 + 32
            , encodedLength = state.encodedLength + 1
            }

        2 ->
            let
                input1 =
                    Bitwise.and state.leftOver 15
                        |> Bitwise.shiftLeftBy 2
                        |> (+) (Bitwise.and n 192 |> Bitwise.shiftRightBy 6)

                input2 =
                    Bitwise.and n 63
            in
            { encoded =
                state.encoded
                    ++ toString input1
                    ++ toString input2
            , leftOver = 0
            , encodedLength = state.encodedLength + 2
            }

        _ ->
            { encoded = state.encoded
            , leftOver = state.leftOver
            , encodedLength = state.encodedLength
            }


finish : Base64State -> String
finish { encoded, leftOver, encodedLength } =
    case Bitwise.shiftRightBy 4 leftOver of
        1 ->
            (Bitwise.and leftOver 3 |> Bitwise.shiftLeftBy 4)
                |> base64Char
                |> String.fromChar
                |> (++) encoded
                |> (\s -> s ++ "==")

        2 ->
            (Bitwise.and leftOver 15 |> Bitwise.shiftLeftBy 2)
                |> base64Char
                |> String.fromChar
                |> (++) encoded
                |> (\s -> s ++ "=")

        _ ->
            encoded


base64Char : Int -> Char
base64Char n =
    case n of
        0 ->
            'A'

        1 ->
            'B'

        2 ->
            'C'

        3 ->
            'D'

        4 ->
            'E'

        5 ->
            'F'

        6 ->
            'G'

        7 ->
            'H'

        8 ->
            'I'

        9 ->
            'J'

        10 ->
            'K'

        11 ->
            'L'

        12 ->
            'M'

        13 ->
            'N'

        14 ->
            'O'

        15 ->
            'P'

        16 ->
            'Q'

        17 ->
            'R'

        18 ->
            'S'

        19 ->
            'T'

        20 ->
            'U'

        21 ->
            'V'

        22 ->
            'W'

        23 ->
            'X'

        24 ->
            'Y'

        25 ->
            'Z'

        26 ->
            'a'

        27 ->
            'b'

        28 ->
            'c'

        29 ->
            'd'

        30 ->
            'e'

        31 ->
            'f'

        32 ->
            'g'

        33 ->
            'h'

        34 ->
            'i'

        35 ->
            'j'

        36 ->
            'k'

        37 ->
            'l'

        38 ->
            'm'

        39 ->
            'n'

        40 ->
            'o'

        41 ->
            'p'

        42 ->
            'q'

        43 ->
            'r'

        44 ->
            's'

        45 ->
            't'

        46 ->
            'u'

        47 ->
            'v'

        48 ->
            'w'

        49 ->
            'x'

        50 ->
            'y'

        51 ->
            'z'

        52 ->
            '0'

        53 ->
            '1'

        54 ->
            '2'

        55 ->
            '3'

        56 ->
            '4'

        57 ->
            '5'

        58 ->
            '6'

        59 ->
            '7'

        60 ->
            '8'

        61 ->
            '9'

        62 ->
            '+'

        63 ->
            '/'

        _ ->
            Char.fromCode 0
