module SearchStatus : sig
  type t = Fail | Timeout | Succ of float * SearchResult.t
  [@@deriving sexp, compare]

  val json_of_succ : float -> SearchResult.t -> Yojson.Safe.t

  val json_of : t -> Yojson.Safe.t

  val of_json : Yojson.Safe.t -> (t, string) Core.Result.t

  val pp : t Fmt.t
end

type t = SearchStatus.t Core.String.Map.t

val json_of : t -> Yojson.Safe.t

val save : string -> t -> unit

val load : string -> (t, string) Core.Result.t
