open BinNums
open Datatypes
open Fappli_IEEE

val ptr64 : bool

val big_endian : bool

val align_int64 : coq_Z

val align_float64 : coq_Z

val splitlong : bool

val default_pl_64 : bool * nan_pl

val choose_binop_pl_64 : bool -> nan_pl -> bool -> nan_pl -> bool

val default_pl_32 : bool * nan_pl

val choose_binop_pl_32 : bool -> nan_pl -> bool -> nan_pl -> bool

val float_of_single_preserves_sNaN : bool
