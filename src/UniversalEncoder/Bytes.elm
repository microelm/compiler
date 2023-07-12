module UniversalEncoder.Bytes exposing (Bytes, Endianness(..))


type alias Bytes =
    String


type Endianness
    = LE
    | BE
