module Wasm.Encode exposing
    ( Binary
    , binary, binaryFromText, text, textFromBinary
    )

{-|


# WebAssembly Encoder

This module provides a set of functions for converting between WebAssembly modules represented as Elm data structures
and WebAssembly binaries or textual representations.


## Types

@docs Binary


## Functions

@docs binary, binaryFromText, text, textFromBinary

-}

import Wasm.Encode.Binary
import Wasm.Encode.Text exposing (functionToText, globalToText, memoryToText, tableToText)
import Wasm.Module exposing (Function, Module)


{-| This is a custom type provided by the Wasm.Encode library for representing a WebAssembly binary.
-}
type alias Binary =
    String


{-| This function takes a WebAssembly textual representation as input and returns a Result String Binary,
where the Binary type is a custom type provided by the Wasm.Encode library.
If the conversion is successful, the result will be an Ok value containing the WebAssembly binary.
If an error occurs, the result will be an Err value containing an error message.
-}
binaryFromText : String -> Result String Binary
binaryFromText str =
    Err "not implemented"


type alias BinaryOptions state =
    { initialState : state
    , addByte : Int -> state -> state
    }


{-| Converts a `Module` value to a WebAssembly binary.
-}
binary : BinaryOptions state -> Module -> state
binary options mod =
    let
        ignoreMe =
            ""
    in
    options.initialState
        |> Wasm.Encode.Binary.sectionHeader options.addByte
        |> Wasm.Encode.Binary.sectionCustom options.addByte ignoreMe
        |> Wasm.Encode.Binary.sectionType options.addByte mod.functions
        |> Wasm.Encode.Binary.sectionImport options.addByte mod.functions
        |> Wasm.Encode.Binary.sectionFunction options.addByte mod.functions
        |> Wasm.Encode.Binary.sectionTable options.addByte mod.functions
        |> Wasm.Encode.Binary.sectionMemory options.addByte mod.functions
        |> Wasm.Encode.Binary.sectionGlobal options.addByte mod.functions
        |> Wasm.Encode.Binary.sectionExport options.addByte mod.functions
        |> Wasm.Encode.Binary.sectionStart options.addByte mod.functions
        |> Wasm.Encode.Binary.sectionElement options.addByte mod.functions
        |> Wasm.Encode.Binary.sectionCode options.addByte mod.functions
        |> Wasm.Encode.Binary.sectionData options.addByte mod.functions



--00 61 73 6d 01 00 00 00 01 05 01 60 00 01 7e 03 18 17 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 81 01 17 02 61 30 00 00 02 61 31 00 01 02 61 32 00 02 02 61 33 00 03 02 61 34 00 04 02 61 35 00 05 02 61 36 00 06 02 61 37 00 07 02 61 38 00 08 02 61 39 00 09 03 61 31 30 00 0a 03 61 31 31 00 0b 03 61 31 32 00 0c 03 61 31 33 00 0d 03 61 31 34 00 0e 03 61 31 35 00 0f 03 61 31 36 00 10 03 61 31 37 00 11 03 61 31 38 00 12 03 61 31 39 00 13 03 61 32 30 00 14 03 61 32 31 00 15 03 61 32 32 00 16 0a 77 17 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 05 00 42 e8 01 0b 05 00 42 e8 01 0b 05 00 42 e8 01 0b 00 36 04 6e 61 6d 65 02 2f 17 00 00 01 00 02 00 03 00 04 00 05 00 06 00 07 00 08 00 09 00 0a 00 0b 00 0c 00 0d 00 0e 00 0f 00 10 00 11 00 12 00 13 00 14 00 15 00 16 00
--00 61 73 6d 01 00 00 00 01 5d 17 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 60 00 01 7e 03 18 17 00 01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f 10 11 12 13 14 15 16 07 81 80 80 80 80 00 17 02 61 30 00 00 02 61 31 00 01 02 61 32 00 02 02 61 33 00 03 02 61 34 00 04 02 61 35 00 05 02 61 36 00 06 02 61 37 00 07 02 61 38 00 08 02 61 39 00 09 03 61 31 30 00 0a 03 61 31 31 00 0b 03 61 31 32 00 0c 03 61 31 33 00 0d 03 61 31 34 00 0e 03 61 31 35 00 0f 03 61 31 36 00 10 03 61 31 37 00 11 03 61 31 38 00 12 03 61 31 39 00 13 03 61 32 30 00 14 03 61 32 31 00 15 03 61 32 32 00 16 0a 77 17 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 04 00 42 0a 0b 05 00 42 e8 01 0b 05 00 42 e8 01 0b 05 00 42 e8 01 0b


{-| Converts a `Module` value to a WebAssembly textual representation.
-}
text : Module -> String
text mod =
    let
        functionTexts =
            List.map functionToText mod.functions

        globalTexts =
            List.map globalToText mod.globals

        tableTexts =
            List.map tableToText mod.tables

        memoryTexts =
            List.map memoryToText mod.memories
    in
    "(module " ++ String.join " " (functionTexts ++ globalTexts ++ tableTexts ++ memoryTexts) ++ " )"


{-| This function takes a WebAssembly binary as input and returns a Result String String,
where the String type is a built-in Elm type. If the conversion is successful,
the result will be an Ok value containing the WebAssembly textual representation.
If an error occurs, the result will be an Err value containing an error message.
-}
textFromBinary : Binary -> Result String String
textFromBinary input =
    Err "not implemented"
