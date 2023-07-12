module Wasm.Instruction exposing (Instruction(..), MemoryImmediate)

{-|


# WebAssembly Instructions

This module provides a set of custom types for representing WebAssembly instructions.


## Types

@docs Instruction, MemoryImmediate

-}

import Wasm.Type exposing (Type)


{-| The `MemoryImmediate` type represents a set of memory access instructions
that take an immediate value as an argument,
such as i32.load, i32.store, i64.load, and i64.store.
The immediate value specifies the alignment and offset of the memory access,
and is used to calculate the effective address of the memory location being accessed.
-}
type alias MemoryImmediate =
    { alignment : Int
    , offset : Int
    }


{-| -}
type Instruction
    = Unreachable
    | Nop
    | Block (List Type) (List Instruction)
    | Loop (List Type) (List Instruction)
    | If (List Type) (List Instruction) (List Instruction)
    | Br Int
    | BrIf Int
    | BrTable (List Int) Int
    | Return
    | Call Int
    | CallIndirect Int
    | Drop
    | Select
    | LocalGet Int
    | LocalSet Int
    | LocalTee Int
    | GlobalGet Int
    | GlobalSet Int
    | Load (List MemoryImmediate)
    | Store (List MemoryImmediate)
    | MemorySize
    | MemoryGrow
    | MemoryFill
    | MemoryCopy
    | MemoryInit
    | DataDrop
    | MemoryData
    | I32Load (List MemoryImmediate)
    | I64Load (List MemoryImmediate)
    | F32Load (List MemoryImmediate)
    | F64Load (List MemoryImmediate)
    | I32Load8S (List MemoryImmediate)
    | I32Load8U (List MemoryImmediate)
    | I32Load16S (List MemoryImmediate)
    | I32Load16U (List MemoryImmediate)
    | I64Load8S (List MemoryImmediate)
    | I64Load8U (List MemoryImmediate)
    | I64Load16S (List MemoryImmediate)
    | I64Load16U (List MemoryImmediate)
    | I64Load32S (List MemoryImmediate)
    | I64Load32U (List MemoryImmediate)
    | I32Store (List MemoryImmediate)
    | I64Store (List MemoryImmediate)
    | F32Store (List MemoryImmediate)
    | F64Store (List MemoryImmediate)
    | I32Store8 (List MemoryImmediate)
    | I32Store16 (List MemoryImmediate)
    | I64Store8 (List MemoryImmediate)
    | I64Store16 (List MemoryImmediate)
    | I64Store32 (List MemoryImmediate)
    | CurrentMemory
    | GrowMemory
    | I32Const Int
    | I64Const Int
    | F32Const Float
    | F64Const Float
    | I32Eqz
    | I32Eq
    | I32Ne
    | I32LtS
    | I32LtU
    | I32GtS
    | I32GtU
    | I32LeS
    | I32LeU
    | I32GeS
    | I32GeU
    | I64Eqz
    | I64Eq
    | I64Ne
    | I64LtS
    | I64LtU
    | I64GtS
    | I64GtU
    | I64LeS
    | I64LeU
    | I64GeS
    | I64GeU
    | F32Eq
    | F32Ne
    | F32Lt
    | F32Gt
    | F32Le
    | F32Ge
    | F64Eq
    | F64Ne
    | F64Lt
    | F64Gt
    | F64Le
    | F64Ge
    | I32Clz
    | I32Ctz
    | I32Popcnt
    | I32Add
    | I32Sub
    | I32Mul
    | I32DivS
    | I32DivU
    | I32RemS
    | I32RemU
    | I32And
    | I32Or
    | I32Xor
    | I32Shl
    | I32ShrS
    | I32ShrU
    | I32Rotl
    | I32Rotr
    | I64Clz
    | I64Ctz
    | I64Popcnt
    | I64Add
    | I64Sub
    | I64Mul
    | I64DivS
    | I64DivU
    | I64RemS
    | I64RemU
    | I64And
    | I64Or
    | I64Xor
    | I64Shl
    | I64ShrS
    | I64ShrU
    | I64Rotl
    | I64Rotr
    | F32Abs
    | F32Neg
    | F32Ceil
    | F32Floor
    | F32Trunc
    | F32Nearest
    | F32Sqrt
    | F32Add
    | F32Sub
    | F32Mul
    | F32Div
    | F32Min
    | F32Max
    | F32CopySign
    | F64Abs
    | F64Neg
    | F64Ceil
    | F64Floor
    | F64Trunc
    | F64Nearest
    | F64Sqrt
    | F64Add
    | F64Sub
    | F64Mul
    | F64Div
    | F64Min
    | F64Max
    | F64CopySign
    | I32WrapI64
    | I32TruncF32S
    | I32TruncF32U
    | I32TruncF64S
    | I32TruncF64U
    | I64ExtendI32S
    | I64ExtendI32U
    | I64TruncF32S
    | I64TruncF32U
    | I64TruncF64S
    | I64TruncF64U
    | F32ConvertI32S
    | F32ConvertI32U
    | F32ConvertI64S
    | F32ConvertI64U
    | F32DemoteF64
    | F64ConvertI32S
    | F64ConvertI32U
    | F64ConvertI64S
    | F64ConvertI64U
    | F64PromoteF32
    | I32ReinterpretF32
    | I64ReinterpretF64
    | F32ReinterpretI32
    | F64ReinterpretI64
