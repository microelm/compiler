module Wasm.Module exposing (Function(..), Global, Memory, Module, Table)

{-|


# WebAssembly Abstract Syntax Tree (AST)

This module provides a set of custom types for representing a WebAssembly module and its elements.


## Types

@docs Function, Global, Memory, Module, Table, Value

-}

import Wasm.Instruction exposing (Instruction)
import Wasm.Type exposing (Type)
import Wasm.Value exposing (Value)


{-| A custom type for representing a complete WebAssembly module in an Elm data structure.

  - `functions`: A list of `Function`s in the module.
  - `globals`: A list of `Global`s in the module.
  - `tables`: A list of `Table`s in the module.
  - `memories`: A list of `Memory`s in the module.

-}
type alias Module =
    { functions : List Function
    , globals : List Global
    , tables : List Table
    , memories : List Memory
    }


{-| A custom type for representing WebAssembly functions in an Elm data structure.

This type has two variants: `FunctionDefined` and `FunctionImport`.


#### `FunctionDefined`

This variant represents a function defined in the WebAssembly module. It has the following fields:

  - `name`: The name of the function.
  - `params`: A list of value types for the function's parameters.
  - `results`: A list of value types for the function's return values.
  - `locals`: A list of value types for the function's local variables.
  - `body`: A list of `Instruction`s representing the function's body.
  - `exported`: A boolean value indicating whether the function is exported from the module.


#### `FunctionImport`

This variant represents a function imported into the WebAssembly module. It has the following fields:

  - `params`: A list of value types for the function's parameters.
  - `results`: A list of value types for the function's return values.
  - `moduleName`: The name of the module from which the function is imported.
  - `fieldName`: The name of the field in the importing module where the function is stored.

-}
type Function
    = FunctionDefined
        { name : String
        , params : List Type
        , results : List Type
        , locals : List Type
        , body : List Instruction
        , exported : Bool
        }
    | FunctionImport
        { params : List Type
        , results : List Type
        , moduleName : String
        , fieldName : String
        }


{-| A custom type for representing WebAssembly global variables.
This type can represent both imported and defined global variables.


## Variants


#### GlobalDefined

A variant representing a global variable defined within the WebAssembly module. It has the following fields:

  - `name`: The name of the global variable.
  - `globalType`: The type of the global variable.
  - `value`: The initial value of the global variable.
  - `exported`: A boolean value indicating whether the global variable is exported from the module.


#### GlobalImport

A variant representing a global variable imported from another module. It has the following fields:

  - `name`: The name of the global variable.
  - `globalType`: The type of the global variable.
  - `moduleName`: The name of the module from which the global variable is imported.
  - `fieldName`: The name of the global variable in the importing module.

-}
type Global
    = GlobalDefined
        { name : String
        , globalType : Type
        , value : Value
        , exported : Bool
        }
    | GlobalImport
        { name : String
        , globalType : Type
        , moduleName : String
        , fieldName : String
        }


{-| A custom type for representing WebAssembly tables.

This type has two variants: `TableDefined` and `TableImport`.


#### `TableDefined`

This variant represents a table defined in the WebAssembly module. It has the following fields:

  - `elementType`: The type of elements stored in the table.
  - `initialSize`: The initial number of elements in the table.
  - `exported`: A boolean value indicating whether the table is exported from the module.


#### `TableImport`

This variant represents a table imported into the WebAssembly module. It has the following fields:

  - `elementType`: The type of elements stored in the table.
  - `initialSize`: The initial number of elements in the table.
  - `moduleName`: The name of the module from which the table is imported.
  - `fieldName`: The name of the field in the importing module where the table is stored.

-}
type Table
    = TableDefined
        { elementType : Type
        , initialSize : Int
        , exported : Bool
        }
    | TableImport
        { elementType : Type
        , initialSize : Int
        , moduleName : String
        , fieldName : String
        }


{-| A custom type for representing WebAssembly memories.

This type has two variants: `MemoryDefined` and `MemoryImport`.


#### `MemoryDefined`

This variant represents a memory defined in the WebAssembly module. It has the following fields:

  - `initial`: The initial number of pages in the memory.
  - `maximum`: The maximum number of pages the memory can grow to. This is an optional field, represented as a `Maybe Int`.
  - `exported`: A boolean value indicating whether the memory is exported from the module.


#### `MemoryImport`

This variant represents a memory imported into the WebAssembly module. It has the following fields:

  - `initial`: The initial number of pages in the memory.
  - `maximum`: The maximum number of pages the memory can grow to. This is an optional field, represented as a `Maybe Int`.
  - `moduleName`: The name of the module from which the memory is imported.
  - `fieldName`: The name of the field in the importing module where the memory is stored.

-}
type Memory
    = MemoryDefined
        { initial : Int
        , maximum : Maybe Int
        , exported : Bool
        }
    | MemoryImport
        { initial : Int
        , maximum : Maybe Int
        , moduleName : String
        , fieldName : String
        }
