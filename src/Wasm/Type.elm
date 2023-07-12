module Wasm.Type exposing (Type(..))

{-|


# WebAssembly Types

This module provides a set of custom types for representing WebAssembly types and type constructors in an Elm data structure.


## Types

@docs Type

-}


{-| A custom type for representing WebAssembly value types.

  - `I32`: 32-bit integer type. Equivalent to `i32` in WebAssembly.
  - `I64`: 64-bit integer type. Equivalent to `i64` in WebAssembly.
  - `F32`: 32-bit floating-point type. Equivalent to `f32` in WebAssembly.
  - `F64`: 64-bit floating-point type. Equivalent to `f64` in WebAssembly.
  - `V128`: 128-bit SIMD vector type. Equivalent to `v128` in WebAssembly.
  - `FuncRef`: Reference to a WebAssembly function. Equivalent to `funcref` in WebAssembly.
  - `ExternRef`: Reference to an external value. Equivalent to `externref` in WebAssembly.
  - `AnyRef`: Reference to any value. Equivalent to `anyref` in WebAssembly.
  - `EqRef`: Reference to a value that is equal. Equivalent to `eqref` in WebAssembly.
  - `I31Ref`: 31-bit integer reference type. Equivalent to `i31ref` in WebAssembly.

-}
type Type
    = I32
    | I64
    | F32
    | F64
    | V128
    | FuncRef
    | ExternRef
    | AnyRef
    | EqRef
    | I31Ref
