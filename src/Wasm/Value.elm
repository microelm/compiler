module Wasm.Value exposing (Value(..))

{-|


# WebAssembly Values

This module provides a set of custom types for representing WebAssembly values and value constructors in an Elm data structure.


## Types

@docs Value

-}


{-| A custom type for representing initial values for WebAssembly global variables.

  - `I32`: Initial value for a 32-bit integer global variable.
  - `I64`: Initial value for a 64-bit integer global variable.
  - `F32`: Initial value for a 32-bit floating-point global variable.
  - `F64`: Initial value for a 64-bit floating-point global variable.
  - `V128`: Initial value for a 128-bit SIMD vector global variable. The value is represented as a list of integers.

-}
type Value
    = I32 Int
    | I64 Int
    | F32 Float
    | F64 Float
    | V128 (List Int)
