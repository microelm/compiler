module Wasm.Encode.Binary exposing
    ( sectionCode
    , sectionCustom
    , sectionData
    , sectionElement
    , sectionExport
    , sectionFunction
    , sectionGlobal
    , sectionHeader
    , sectionImport
    , sectionMemory
    , sectionStart
    , sectionTable
    , sectionType
    )

import Bitwise
import Wasm.Encode.Leb128 exposing (leb128s)
import Wasm.Instruction as Instruction exposing (Instruction)
import Wasm.Module exposing (Function(..), Global, Memory, Table)
import Wasm.Type as Type exposing (Type)


type alias AddByte state =
    Int -> state -> state



-- TODO update BinaryCounter
--type BinaryCounter2
--    = BinaryCounter2 (List BinaryCounter2) Int
--    | BinaryCounter2One Int


type BinaryCounter
    = BinaryCounter (List Int) Int


addOne : Int -> BinaryCounter -> BinaryCounter
addOne x xs =
    case xs of
        BinaryCounter aa c ->
            BinaryCounter (x :: aa) (c + 1)


addMany : BinaryCounter -> BinaryCounter -> BinaryCounter
addMany x xs =
    case xs of
        BinaryCounter aa c ->
            let
                (BinaryCounter one c2) =
                    x
            in
            BinaryCounter (one ++ aa) (c + c2)


foldlBinaryCounter func acc (BinaryCounter a _) =
    List.foldl func acc (List.reverse a)


{-| The Header section, write the magic number and version number to the binary.
-}
sectionHeader : AddByte state -> state -> state
sectionHeader addByte state =
    let
        doEncode fn list acc =
            List.foldl (fn addByte) acc list

        magicNumber : List Int
        magicNumber =
            [ 0x00, 0x61, 0x73, 0x6D ]

        versionNumber : List Int
        versionNumber =
            [ 0x01, 0x00, 0x00, 0x00 ]
    in
    state
        |> doEncode identity magicNumber
        |> doEncode identity versionNumber


{-| Custom sections are a way to include additional information or metadata in a WebAssembly module.
They can be used to include information such as debugging symbols, function names, and other custom data that is not part of the WebAssembly specification.
Custom sections are identified by their name, which is a null-terminated string, and their payload, which is a sequence of bytes.
-}
sectionCustom : AddByte state -> String -> state -> state
sectionCustom addByte payload state =
    state


{-| Encodes the Type section of a WebAssembly module.
-}
sectionType : AddByte state -> List Function -> state -> state
sectionType addByte functions state =
    let
        ( (BinaryCounter _ bytesCount) as bytes, functionCount ) =
            List.foldl (\fn ( list, c2 ) -> ( encodeFunctionTypeBinaryCounter fn list, c2 + 1 )) ( BinaryCounter [] 0, 0 ) functions

        ((BinaryCounter _ bytesCount2) as numTypes) =
            encodeVarUIntBinaryCounter functionCount

        sectionSize =
            encodeVarUIntBinaryCounter (bytesCount2 + bytesCount)
    in
    BinaryCounter [ {- ; section code -} 0x01 ] 1
        |> addMany sectionSize
        |> addMany numTypes
        |> addMany bytes
        |> foldlBinaryCounter addByte state


{-| The Import section, which lists the imported functions, globals, tables, and memories.
-}
sectionImport : AddByte state -> List Function -> state -> state
sectionImport addByte functions state =
    state


{-| The Function section, which lists the function indices of the functions defined in the module.
-}
sectionFunction : AddByte state -> List Function -> state -> state
sectionFunction addByte fns state =
    let
        ( (BinaryCounter _ bytesCount) as indexes, functionCount ) =
            List.foldl (\_ ( acc, i ) -> ( addOne i acc, i + 1 )) ( BinaryCounter [] 0, 0 ) fns

        ((BinaryCounter _ bytesCount2) as numFunctions) =
            encodeVarUIntBinaryCounter functionCount

        sectionSize =
            encodeVarUIntBinaryCounter (bytesCount2 + bytesCount)
    in
    BinaryCounter [ {- ; section code -} 0x03 ] 1
        |> addMany sectionSize
        |> addMany numFunctions
        |> addMany indexes
        |> foldlBinaryCounter addByte state


{-| The Table section, which defines the tables used in the module.
-}
sectionTable : AddByte state -> List Function -> state -> state
sectionTable addByte fns state =
    state


{-| The Memory section, which defines the memories used in the module.
-}
sectionMemory : AddByte state -> List Function -> state -> state
sectionMemory addByte fns state =
    state


{-| The Global section, which defines the global variables used in the module.
-}
sectionGlobal : AddByte state -> List Function -> state -> state
sectionGlobal addByte fns state =
    state


{-| The Export section, which lists the functions, globals, tables, and memories that are exported from the module.
-}
sectionExport : AddByte state -> List Function -> state -> state
sectionExport addByte functions state =
    let
        ( ( (BinaryCounter _ bytesCount) as exports, exportsCount ), _ ) =
            List.foldl
                (\fn ( acc, index ) ->
                    ( encodeExportBinaryCounter fn index acc
                    , index + 1
                    )
                )
                ( ( BinaryCounter [] 0, 0 ), 0 )
                functions

        ((BinaryCounter _ bytesCount2) as numExports) =
            encodeVarUIntBinaryCounter exportsCount

        sectionSize =
            encodeVarUIntBinaryCounter (bytesCount2 + bytesCount)
    in
    BinaryCounter [ {- ; section code -} 0x07 ] 1
        |> addMany sectionSize
        |> addMany numExports
        |> addMany exports
        |> foldlBinaryCounter addByte state


{-| The Start section, which specifies the function index of the function to be executed when the module is instantiated.
-}
sectionStart : AddByte state -> List Function -> state -> state
sectionStart addByte fns state =
    state


{-| The Element section, which specifies the initialization of tables with elements.
-}
sectionElement : AddByte state -> List Function -> state -> state
sectionElement addByte fns state =
    state


{-| The Code section, which contains the function bodies of the functions defined in the module.
-}
sectionCode : AddByte state -> List Function -> state -> state
sectionCode addByte functions state =
    let
        ( (BinaryCounter _ bytesCount) as bytes, functionCount ) =
            List.foldl (\fn ( list, c2 ) -> ( encodeFunctionBodyBinaryCounter fn list, c2 + 1 )) ( BinaryCounter [] 0, 0 ) functions

        ((BinaryCounter _ bytesCount2) as numFunctions) =
            encodeVarUIntBinaryCounter functionCount

        sectionSize =
            encodeVarUIntBinaryCounter (bytesCount2 + bytesCount)

        _ =
            Debug.log "sectionCode::numFunctions" numFunctions
    in
    BinaryCounter [ {- ; section code -} 0x0A ] 1
        |> addMany sectionSize
        |> addMany numFunctions
        |> addMany bytes
        |> foldlBinaryCounter addByte state


{-| The Data section, which initializes memories with data.
-}
sectionData : AddByte state -> List Function -> state -> state
sectionData addByte fns state =
    state


encodeString : String -> BinaryCounter
encodeString string =
    let
        nameSize =
            String.length string
    in
    BinaryCounter [ nameSize ] 1
        |> addMany (BinaryCounter (string |> String.toList |> List.reverse |> List.map Char.toCode) nameSize)


encodeExportBinaryCounter : Function -> Int -> ( BinaryCounter, Int ) -> ( BinaryCounter, Int )
encodeExportBinaryCounter function index ( result, count ) =
    case function of
        FunctionDefined { name, exported } ->
            if exported then
                ( result
                    |> addMany (encodeString name)
                    |> addOne {- ; export kind -} 0x00
                    |> addOne {- ; export func index -} index
                , count + 1
                )

            else
                ( result, count )

        FunctionImport _ ->
            ( result, count )


encodeFunctionTypeBinaryCounter : Function -> BinaryCounter -> BinaryCounter
encodeFunctionTypeBinaryCounter function counter =
    case function of
        FunctionDefined { params, results } ->
            let
                ((BinaryCounter _ pCount) as pp) =
                    List.foldl (convertType >> addOne) (BinaryCounter [] 0) params

                ((BinaryCounter _ rCount) as rr) =
                    List.foldl (convertType >> addOne) (BinaryCounter [] 0) results
            in
            counter
                |> addMany (BinaryCounter [ 0x60 ] 1)
                |> addMany (encodeVarUIntBinaryCounter pCount)
                |> addMany pp
                |> addMany (encodeVarUIntBinaryCounter rCount)
                |> addMany rr

        FunctionImport { params, results, moduleName, fieldName } ->
            -- TODO: Implement encoding of imported function types
            counter


encodeFunctionBodyBinaryCounter : Function -> BinaryCounter -> BinaryCounter
encodeFunctionBodyBinaryCounter function counter =
    case function of
        FunctionDefined { locals, body } ->
            let
                ((BinaryCounter _ bytesCount1) as localsCode) =
                    List.foldl (convertType >> addOne) (BinaryCounter [] 0) locals

                ((BinaryCounter _ bytesCount2) as localDeclCount) =
                    encodeVarUIntBinaryCounter bytesCount1

                ((BinaryCounter _ instSize) as inst) =
                    List.foldl (encodeInstruction >> addMany) (BinaryCounter [] 0) body
                        |> {- ; end -} addOne 0x0B

                bodySize =
                    bytesCount1
                        |> (+) bytesCount2
                        |> (+) instSize
            in
            counter
                |> addMany (encodeVarUIntBinaryCounter bodySize)
                |> addMany localDeclCount
                |> addMany localsCode
                |> addMany inst

        FunctionImport { params, results, moduleName, fieldName } ->
            counter


encodeInstruction : Instruction -> BinaryCounter
encodeInstruction instruction =
    -- https://pengowray.github.io/wasm-ops/
    case instruction of
        Instruction.Call value ->
            BinaryCounter [ 0x10 ] 1
                |> addMany (encodeVarUIntBinaryCounter value)

        Instruction.I32Const value ->
            BinaryCounter [ 0x41 ] 1
                |> addMany (List.foldl addOne (BinaryCounter [] 0) (leb128s value))

        Instruction.I64Const value ->
            BinaryCounter [ 0x42 ] 1
                |> addMany (List.foldl addOne (BinaryCounter [] 0) (leb128s value))

        Instruction.LocalGet value ->
            BinaryCounter [ 0x20 ] 1
                |> addMany (encodeVarUIntBinaryCounter value)

        Instruction.I64Add ->
            BinaryCounter [ 0x7C ] 1

        Instruction.I32Sub ->
            BinaryCounter [ 0x6B ] 1

        Instruction.I64Sub ->
            BinaryCounter [ 0x7D ] 1

        Instruction.I32Mul ->
            BinaryCounter [ 0x6C ] 1

        Instruction.I64Mul ->
            BinaryCounter [ 0x7E ] 1

        Instruction.I32DivS ->
            BinaryCounter [ 0x6D ] 1

        Instruction.I64DivS ->
            BinaryCounter [ 0x7F ] 1

        Instruction.I32RemS ->
            BinaryCounter [ 0x6F ] 1

        Instruction.I64RemS ->
            BinaryCounter [ 0x81 ] 1

        _ ->
            BinaryCounter [] 0


encodeVarUIntBinaryCounter : Int -> BinaryCounter
encodeVarUIntBinaryCounter n =
    encodeVarUInt addOne n (BinaryCounter [] 0)


encodeVarUInt : AddByte state -> Int -> state -> state
encodeVarUInt addByte n state =
    if n < 0x80 then
        addByte n state

    else
        state
            |> addByte (0x80 + Bitwise.and n 0x7F)
            |> encodeVarUInt addByte (Bitwise.shiftRightBy 7 n)


convertType : Type -> Int
convertType t =
    case t of
        Type.I32 ->
            0x7F

        Type.I64 ->
            0x7E

        Type.F32 ->
            0x7D

        Type.F64 ->
            0x7C

        Type.V128 ->
            0x7B

        Type.FuncRef ->
            0x70

        Type.ExternRef ->
            0x6F

        Type.AnyRef ->
            0x6E

        Type.EqRef ->
            0x6D

        Type.I31Ref ->
            0x6C
