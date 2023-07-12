module Wasm.Encode.Leb128 exposing (leb128s)

import Bitwise


leb128s value =
    if value > 0 then
        leb128sPositive [] value

    else
        leb128sNegative [] value


leb128sPositive bytes input =
    let
        byte =
            Bitwise.and 127 input

        value =
            Bitwise.shiftRightBy 7 input
    in
    if value == 0 && Bitwise.and 0x40 byte == 0 then
        List.reverse (byte :: bytes)

    else
        leb128sPositive (Bitwise.or 128 byte :: bytes) value


leb128sNegative bytes_ input_ =
    let
        size =
            ceiling (logBase 2 (abs (toFloat input_)))

        loop bytes input =
            let
                byte =
                    Bitwise.and 127 input

                value1 =
                    Bitwise.shiftRightBy 7 input

                value =
                    Bitwise.or value1 -(Bitwise.shiftLeftBy (size - 7) 1)
            in
            if value == -1 && Bitwise.and 0x40 byte == 0x40 then
                List.reverse (byte :: bytes)

            else
                loop (Bitwise.or 128 byte :: bytes) value
    in
    loop bytes_ input_
