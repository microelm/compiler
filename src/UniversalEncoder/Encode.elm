module UniversalEncoder.Encode exposing
    ( Encoder(..)
    , bit
    , encode
    , float32
    , float64
    , sequence
    , signedInt16
    , signedInt24
    , signedInt32
    , signedInt8
    , unsignedInt16
    , unsignedInt24
    , unsignedInt32
    , unsignedInt8
    )

import Bitwise
import UniversalEncoder.Bytes exposing (Bytes, Endianness(..))


type Encoder
    = Sequence (List Encoder)
    | Byte Int
    | Bit Bool


sequence : List Encoder -> Encoder
sequence encoders =
    Sequence encoders


signedInt8 : Int -> Encoder
signedInt8 n =
    Byte n


signedInt16 : Endianness -> Int -> Encoder
signedInt16 =
    unsignedInt16


signedInt32 : Endianness -> Int -> Encoder
signedInt32 =
    unsignedInt32


unsignedInt8 : Int -> Encoder
unsignedInt8 n =
    Byte n


unsignedInt16 : Endianness -> Int -> Encoder
unsignedInt16 endianness x =
    case endianness of
        LE ->
            Sequence
                [ Byte (Bitwise.and 0xFF x)
                , Byte (Bitwise.shiftRightBy 8 x)
                ]

        BE ->
            Sequence
                [ Byte (Bitwise.shiftRightBy 8 x)
                , Byte (Bitwise.and 0xFF x)
                ]


unsignedInt32 : Endianness -> Int -> Encoder
unsignedInt32 endianness x =
    case endianness of
        LE ->
            Sequence
                [ Byte (Bitwise.and 0xFF x)
                , Byte (Bitwise.shiftRightBy 8 (Bitwise.and 0xFF00 x))
                , Byte (Bitwise.shiftRightBy 16 (Bitwise.and 0x00FF0000 x))
                , Byte (Bitwise.shiftRightBy 24 x)
                ]

        BE ->
            Sequence
                [ Byte (Bitwise.shiftRightBy 24 x)
                , Byte (Bitwise.shiftRightBy 16 (Bitwise.and 0x00FF0000 x))
                , Byte (Bitwise.shiftRightBy 8 (Bitwise.and 0xFF00 x))
                , Byte (Bitwise.and 0xFF x)
                ]


float32 : Float -> Encoder
float32 x =
    Sequence []


float64 : Endianness -> Float -> Encoder
float64 endianness n =
    Sequence []



{--- Custom Stuff --}


unsignedInt24 : Endianness -> Int -> Encoder
unsignedInt24 endianness x =
    case endianness of
        LE ->
            Sequence
                [ Byte (Bitwise.and 0xFF x)
                , Byte (Bitwise.shiftRightBy 8 (Bitwise.and 0xFF00 x))
                , Byte (Bitwise.shiftRightBy 16 (Bitwise.and 0x00FF0000 x))
                ]

        BE ->
            Sequence
                [ Byte (Bitwise.shiftRightBy 16 (Bitwise.and 0x00FF0000 x))
                , Byte (Bitwise.shiftRightBy 8 (Bitwise.and 0xFF00 x))
                , Byte (Bitwise.and 0xFF x)
                ]


signedInt24 : Endianness -> Int -> Encoder
signedInt24 =
    unsignedInt24


bit : Bool -> Encoder
bit n =
    Bit n


type alias InternalState state =
    { currentByte : Int
    , count : Int
    , state : state
    }


encode : (Int -> state -> state) -> state -> Encoder -> state
encode convert stateInput encoderInput =
    let
        encode_ : Encoder -> InternalState state -> InternalState state
        encode_ encoder internalState =
            case encoder of
                Sequence encoders ->
                    List.foldl encode_ internalState encoders

                Byte n ->
                    if internalState.count == 0 then
                        { internalState | state = convert n internalState.state }

                    else
                        let
                            newByte =
                                Bitwise.shiftLeftBy (8 - internalState.count) internalState.currentByte
                                    |> (+) (Bitwise.shiftRightBy internalState.count n)

                            mask =
                                List.range 0 (internalState.count - 1)
                                    |> List.foldl (\i -> Bitwise.or (Bitwise.shiftLeftBy i 1)) 0
                        in
                        { state = convert newByte internalState.state
                        , currentByte = Bitwise.and mask n
                        , count = internalState.count
                        }

                Bit bool ->
                    let
                        intBit =
                            if bool then
                                1

                            else
                                0

                        newInternalState =
                            { internalState
                                | currentByte = Bitwise.shiftLeftBy 1 internalState.currentByte + intBit
                                , count = internalState.count + 1
                            }
                    in
                    if newInternalState.count > 7 then
                        { state = convert newInternalState.currentByte newInternalState.state
                        , currentByte = 0
                        , count = 0
                        }

                    else
                        newInternalState

        resultState =
            encode_ encoderInput { currentByte = 0, count = 0, state = stateInput }
    in
    .state
        (if resultState.count > 0 then
            { currentByte = 0, count = 0, state = resultState.state }
                |> encode_ (Byte (Bitwise.shiftLeftBy (8 - resultState.count) resultState.currentByte))

         else
            resultState
        )
