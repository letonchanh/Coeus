open Archi
open BinNums
open BinPos
open Coqlib
open Datatypes
open Fappli_IEEE
open Fappli_IEEE_bits
open Fappli_IEEE_extra
open Fcore_Zaux
open Integers

type float = binary64

type float32 = binary32

(** val cmp_of_comparison :
    comparison -> Datatypes.comparison option -> bool **)

let cmp_of_comparison c x =
  match c with
  | Ceq ->
    (match x with
     | Some c0 -> (match c0 with
                   | Eq -> true
                   | _ -> false)
     | None -> false)
  | Cne ->
    (match x with
     | Some c0 -> (match c0 with
                   | Eq -> false
                   | _ -> true)
     | None -> true)
  | Clt ->
    (match x with
     | Some c0 -> (match c0 with
                   | Lt -> true
                   | _ -> false)
     | None -> false)
  | Cle ->
    (match x with
     | Some c0 -> (match c0 with
                   | Gt -> false
                   | _ -> true)
     | None -> false)
  | Cgt ->
    (match x with
     | Some c0 -> (match c0 with
                   | Gt -> true
                   | _ -> false)
     | None -> false)
  | Cge ->
    (match x with
     | Some c0 -> (match c0 with
                   | Lt -> false
                   | _ -> true)
     | None -> false)

module Float =
 struct
  (** val transform_quiet_pl : nan_pl -> nan_pl **)

  let transform_quiet_pl pl =
    Pos.coq_lor pl
      (iter_nat (fun x -> Coq_xO x) (S (S (S (S (S (S (S (S (S (S (S (S (S (S
        (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
        (S (S (S (S (S (S (S (S (S (S (S (S (S (S
        O))))))))))))))))))))))))))))))))))))))))))))))))))) Coq_xH)

  (** val expand_pl : nan_pl -> nan_pl **)

  let expand_pl pl =
    Pos.shiftl_nat pl (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
      (S (S (S (S (S (S (S (S (S (S (S O)))))))))))))))))))))))))))))

  (** val of_single_pl : bool -> nan_pl -> bool * nan_pl **)

  let of_single_pl s pl =
    (s,
      (if float_of_single_preserves_sNaN
       then expand_pl pl
       else transform_quiet_pl (expand_pl pl)))

  (** val reduce_pl : nan_pl -> nan_pl **)

  let reduce_pl pl =
    Pos.shiftr_nat pl (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S (S
      (S (S (S (S (S (S (S (S (S (S (S O)))))))))))))))))))))))))))))

  (** val to_single_pl : bool -> nan_pl -> bool * nan_pl **)

  let to_single_pl s pl =
    (s, (reduce_pl (transform_quiet_pl pl)))

  (** val neg_pl : bool -> nan_pl -> bool * nan_pl **)

  let neg_pl s pl =
    ((negb s), pl)

  (** val abs_pl : bool -> nan_pl -> bool * nan_pl **)

  let abs_pl _ pl =
    (false, pl)

  (** val binop_pl : binary64 -> binary64 -> bool * nan_pl **)

  let binop_pl x y =
    match x with
    | B754_nan (s1, pl1) ->
      (match y with
       | B754_nan (s2, pl2) ->
         if choose_binop_pl_64 s1 pl1 s2 pl2
         then (s2, (transform_quiet_pl pl2))
         else (s1, (transform_quiet_pl pl1))
       | _ -> (s1, (transform_quiet_pl pl1)))
    | _ ->
      (match y with
       | B754_nan (s2, pl2) -> (s2, (transform_quiet_pl pl2))
       | _ -> default_pl_64)

  (** val zero : float **)

  let zero =
    B754_zero false

  (** val eq_dec : float -> float -> bool **)

  let eq_dec =
    coq_Beq_dec (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH))))))
      (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO (Coq_xO Coq_xH)))))))))))

  (** val neg : float -> float **)

  let neg =
    coq_Bopp (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH)))))) (Zpos
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO Coq_xH))))))))))) neg_pl

  (** val abs : float -> float **)

  let abs =
    coq_Babs (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH)))))) (Zpos
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO Coq_xH))))))))))) abs_pl

  (** val add : float -> float -> float **)

  let add =
    coq_Bplus (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH))))))
      (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO (Coq_xO Coq_xH))))))))))) binop_pl Coq_mode_NE

  (** val sub : float -> float -> float **)

  let sub =
    coq_Bminus (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH))))))
      (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO (Coq_xO Coq_xH))))))))))) binop_pl Coq_mode_NE

  (** val mul : float -> float -> float **)

  let mul =
    coq_Bmult (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH))))))
      (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO (Coq_xO Coq_xH))))))))))) binop_pl Coq_mode_NE

  (** val div : float -> float -> float **)

  let div =
    coq_Bdiv (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH)))))) (Zpos
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO Coq_xH))))))))))) binop_pl Coq_mode_NE

  (** val cmp : comparison -> float -> float -> bool **)

  let cmp c f1 f2 =
    cmp_of_comparison c
      (coq_Bcompare (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI
        Coq_xH)))))) (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
        (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH))))))))))) f1 f2)

  (** val of_single : float32 -> float **)

  let of_single =
    coq_Bconv (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos (Coq_xO
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH)))))))) (Zpos
      (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH)))))) (Zpos (Coq_xO
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      Coq_xH))))))))))) of_single_pl Coq_mode_NE

  (** val to_single : float -> float32 **)

  let to_single =
    coq_Bconv (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH))))))
      (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO (Coq_xO Coq_xH))))))))))) (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI
      Coq_xH))))) (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO Coq_xH)))))))) to_single_pl Coq_mode_NE

  (** val to_int : float -> Int.int option **)

  let to_int f =
    option_map Int.repr
      (coq_ZofB_range (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI
        Coq_xH)))))) (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
        (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH))))))))))) f Int.min_signed
        Int.max_signed)

  (** val to_intu : float -> Int.int option **)

  let to_intu f =
    option_map Int.repr
      (coq_ZofB_range (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI
        Coq_xH)))))) (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
        (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH))))))))))) f Z0
        Int.max_unsigned)

  (** val to_long : float -> Int64.int option **)

  let to_long f =
    option_map Int64.repr
      (coq_ZofB_range (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI
        Coq_xH)))))) (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
        (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH))))))))))) f Int64.min_signed
        Int64.max_signed)

  (** val to_longu : float -> Int64.int option **)

  let to_longu f =
    option_map Int64.repr
      (coq_ZofB_range (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI
        Coq_xH)))))) (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
        (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH))))))))))) f Z0
        Int64.max_unsigned)

  (** val of_int : Int.int -> float **)

  let of_int n =
    coq_BofZ (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH)))))) (Zpos
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO Coq_xH))))))))))) (Int.signed n)

  (** val of_intu : Int.int -> float **)

  let of_intu n =
    coq_BofZ (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH)))))) (Zpos
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO Coq_xH))))))))))) (Int.unsigned n)

  (** val of_long : Int64.int -> float **)

  let of_long n =
    coq_BofZ (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH)))))) (Zpos
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO Coq_xH))))))))))) (Int64.signed n)

  (** val of_longu : Int64.int -> float **)

  let of_longu n =
    coq_BofZ (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH)))))) (Zpos
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO Coq_xH))))))))))) (Int64.unsigned n)

  (** val from_parsed : positive -> positive -> coq_Z -> float **)

  let from_parsed base intPart expPart =
    coq_Bparse (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI Coq_xH))))))
      (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO (Coq_xO Coq_xH))))))))))) base intPart expPart

  (** val to_bits : float -> Int64.int **)

  let to_bits f =
    Int64.repr (bits_of_b64 f)

  (** val of_bits : Int64.int -> float **)

  let of_bits b =
    b64_of_bits (Int64.unsigned b)

  (** val exact_inverse : float -> float option **)

  let exact_inverse =
    coq_Bexact_inverse (Zpos (Coq_xI (Coq_xO (Coq_xI (Coq_xO (Coq_xI
      Coq_xH)))))) (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH)))))))))))

  (** val ox8000_0000 : Int.int **)

  let ox8000_0000 =
    Int.repr Int.half_modulus
 end

module Float32 =
 struct
  (** val transform_quiet_pl : nan_pl -> nan_pl **)

  let transform_quiet_pl pl =
    Pos.coq_lor pl
      (iter_nat (fun x -> Coq_xO x) (S (S (S (S (S (S (S (S (S (S (S (S (S (S
        (S (S (S (S (S (S (S (S O)))))))))))))))))))))) Coq_xH)

  (** val neg_pl : bool -> nan_pl -> bool * nan_pl **)

  let neg_pl s pl =
    ((negb s), pl)

  (** val abs_pl : bool -> nan_pl -> bool * nan_pl **)

  let abs_pl _ pl =
    (false, pl)

  (** val binop_pl : binary32 -> binary32 -> bool * nan_pl **)

  let binop_pl x y =
    match x with
    | B754_nan (s1, pl1) ->
      (match y with
       | B754_nan (s2, pl2) ->
         if choose_binop_pl_32 s1 pl1 s2 pl2
         then (s2, (transform_quiet_pl pl2))
         else (s1, (transform_quiet_pl pl1))
       | _ -> (s1, (transform_quiet_pl pl1)))
    | _ ->
      (match y with
       | B754_nan (s2, pl2) -> (s2, (transform_quiet_pl pl2))
       | _ -> default_pl_32)

  (** val zero : float32 **)

  let zero =
    B754_zero false

  (** val eq_dec : float32 -> float32 -> bool **)

  let eq_dec =
    coq_Beq_dec (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH))))))))

  (** val neg : float32 -> float32 **)

  let neg =
    coq_Bopp (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos (Coq_xO
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH)))))))) neg_pl

  (** val abs : float32 -> float32 **)

  let abs =
    coq_Babs (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos (Coq_xO
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH)))))))) abs_pl

  (** val add : float32 -> float32 -> float32 **)

  let add =
    coq_Bplus (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos (Coq_xO
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH)))))))) binop_pl
      Coq_mode_NE

  (** val sub : float32 -> float32 -> float32 **)

  let sub =
    coq_Bminus (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH))))))))
      binop_pl Coq_mode_NE

  (** val mul : float32 -> float32 -> float32 **)

  let mul =
    coq_Bmult (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos (Coq_xO
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH)))))))) binop_pl
      Coq_mode_NE

  (** val div : float32 -> float32 -> float32 **)

  let div =
    coq_Bdiv (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos (Coq_xO
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH)))))))) binop_pl
      Coq_mode_NE

  (** val cmp : comparison -> float32 -> float32 -> bool **)

  let cmp c f1 f2 =
    cmp_of_comparison c
      (coq_Bcompare (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos
        (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
        Coq_xH)))))))) f1 f2)

  (** val to_int : float32 -> Int.int option **)

  let to_int f =
    option_map Int.repr
      (coq_ZofB_range (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos
        (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
        Coq_xH)))))))) f Int.min_signed Int.max_signed)

  (** val to_intu : float32 -> Int.int option **)

  let to_intu f =
    option_map Int.repr
      (coq_ZofB_range (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos
        (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
        Coq_xH)))))))) f Z0 Int.max_unsigned)

  (** val to_long : float32 -> Int64.int option **)

  let to_long f =
    option_map Int64.repr
      (coq_ZofB_range (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos
        (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
        Coq_xH)))))))) f Int64.min_signed Int64.max_signed)

  (** val to_longu : float32 -> Int64.int option **)

  let to_longu f =
    option_map Int64.repr
      (coq_ZofB_range (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos
        (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
        Coq_xH)))))))) f Z0 Int64.max_unsigned)

  (** val of_int : Int.int -> float32 **)

  let of_int n =
    coq_BofZ (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos (Coq_xO
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH))))))))
      (Int.signed n)

  (** val of_intu : Int.int -> float32 **)

  let of_intu n =
    coq_BofZ (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos (Coq_xO
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH))))))))
      (Int.unsigned n)

  (** val of_long : Int64.int -> float32 **)

  let of_long n =
    coq_BofZ (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos (Coq_xO
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH))))))))
      (Int64.signed n)

  (** val of_longu : Int64.int -> float32 **)

  let of_longu n =
    coq_BofZ (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos (Coq_xO
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH))))))))
      (Int64.unsigned n)

  (** val from_parsed : positive -> positive -> coq_Z -> float32 **)

  let from_parsed base intPart expPart =
    coq_Bparse (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH))))) (Zpos
      (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO Coq_xH))))))))
      base intPart expPart

  (** val to_bits : float32 -> Int.int **)

  let to_bits f =
    Int.repr (bits_of_b32 f)

  (** val of_bits : Int.int -> float32 **)

  let of_bits b =
    b32_of_bits (Int.unsigned b)

  (** val exact_inverse : float32 -> float32 option **)

  let exact_inverse =
    coq_Bexact_inverse (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xI Coq_xH)))))
      (Zpos (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO (Coq_xO
      Coq_xH))))))))
 end
