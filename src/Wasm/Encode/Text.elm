module Wasm.Encode.Text exposing (..)

import Wasm.Instruction as Instruction exposing (Instruction)
import Wasm.Module exposing (Function(..), Global, Memory, Table)
import Wasm.Type as Type exposing (Type)


globalToText : Global -> String
globalToText global =
    ""


tableToText : Table -> String
tableToText table =
    ""


memoryToText : Memory -> String
memoryToText memory =
    ""


functionToText : Function -> String
functionToText function =
    case function of
        FunctionDefined { name, params, results, locals, body, exported } ->
            let
                paramText =
                    joinList "param" (List.map typeToText params)

                resultText =
                    joinList "result" (List.map typeToText results)

                localText =
                    joinList "local" (List.map typeToText locals)

                bodyToText =
                    List.map instructionToText body

                exportText =
                    if exported then
                        "(export \"" ++ name ++ "\")"

                    else
                        " $" ++ name
            in
            "(func "
                ++ exportText
                ++ " "
                ++ paramText
                ++ " "
                ++ resultText
                ++ " "
                ++ localText
                ++ " "
                ++ String.join " " bodyToText
                ++ ")"

        FunctionImport { params, results, moduleName, fieldName } ->
            let
                paramText =
                    joinList "param" (List.map typeToText params)

                resultText =
                    joinList "result" (List.map typeToText results)
            in
            "(import \""
                ++ moduleName
                ++ "\" \""
                ++ fieldName
                ++ "\" (func"
                ++ paramText
                ++ resultText
                ++ "))"


typeToText : Type -> String
typeToText t =
    case t of
        Type.I32 ->
            "i32"

        Type.I64 ->
            "i64"

        Type.F32 ->
            "f32"

        Type.F64 ->
            "f64"

        Type.V128 ->
            "v128"

        Type.FuncRef ->
            "funcref"

        Type.ExternRef ->
            "externref"

        Type.AnyRef ->
            "anyref"

        Type.EqRef ->
            "eqref"

        Type.I31Ref ->
            "i31ref"


instructionToText : Instruction -> String
instructionToText instruction =
    case instruction of
        Instruction.Call value ->
            "call " ++ String.fromInt value

        Instruction.LocalGet value ->
            "local.get " ++ String.fromInt value

        Instruction.I64Add ->
            "i64.add"

        Instruction.I64Const i ->
            "i64.const " ++ String.fromInt i

        Instruction.I32Const i ->
            "i32.const " ++ String.fromInt i

        Instruction.I32Add ->
            "i32.add"

        Instruction.I32Sub ->
            "i32.sub"

        Instruction.I64Sub ->
            "i64.sub"

        Instruction.I32Mul ->
            "i32.mul"

        Instruction.I64Mul ->
            "i64.mul"

        Instruction.I32DivS ->
            "i32.div_s"

        Instruction.I64DivS ->
            "i64.div_s"

        Instruction.I32RemS ->
            "i32.rem_s"

        Instruction.I64RemS ->
            "i64.rem_s"

        Instruction.Return ->
            "return"

        _ ->
            ""


joinList : String -> List String -> String
joinList keyword values =
    if List.isEmpty values then
        ""

    else
        "(" ++ keyword ++ " " ++ String.join " " values ++ ")"
