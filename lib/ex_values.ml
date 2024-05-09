open Core

type value = ..

type value +=
  | Nil
  | Boolean of bool
  | String of string
  | Number of float

(* this is such a bad idea i'm pretty sure LOL *)
let address (obj : 'a) =
  let id = Obj.repr obj in
  (Obj.magic id : int)
;;

module FloatUtils = struct
  let is_int f =
    let floored = Stdlib.floor f in
    Float.equal f floored, Float.to_int floored
  ;;
end

module LuaFormatter = struct
  let pp_float fmt f =
    match FloatUtils.is_int f with
    | true, int -> Format.pp_print_int fmt int
    | false, _ -> Format.pp_print_float fmt f
  ;;
end

module rec NumberValues : sig
  type t

  val equal : t -> t -> bool
  val compare : t -> t -> int
  val pp : Formatter.t -> t -> unit
  val of_fields : (Value.t option * Value.t) list -> t
end = struct
  type t = (float, Value.t) Hashtbl.t

  let compare a b = Stdlib.compare (address a) (address b)
  let equal a b = compare a b = 0

  let pp fmt (t : t) =
    Format.pp_print_string fmt "{";
    Hashtbl.iteri t ~f:(fun ~key ~data ->
      let _, _ = key, data in
      Format.fprintf
        fmt
        "%a = %a, "
        LuaFormatter.pp_float
        key
        Value.pp
        data);
    Format.pp_print_string fmt "}";
    ()
  ;;

  let of_fields (fields : (Value.t option * Value.t) list) =
    let tbl : t = Hashtbl.create (module Float) in
    let idx = ref 0.0 in
    List.iter fields ~f:(fun (key, value) ->
      match key with
      | Some (Number key) ->
        Hashtbl.add tbl ~key ~data:value |> ignore
      | Some _ -> ()
      | None ->
        idx := !idx +. 1.0;
        Hashtbl.add tbl ~key:!idx ~data:value |> ignore);
    tbl
  ;;
end

and LuaTable : sig
  type t =
    { identifier : Identifier.t
    ; numbers : NumberValues.t
    }
  [@@deriving show, ord, eq]
end = struct
  type t =
    { identifier : Identifier.t
    ; numbers : NumberValues.t
    }
  [@@deriving show { with_path = false }, ord, eq]

  (* (* let show *) *)
  (* let pp fmt t = Identifier.pp fmt t.identifier *)
  (* let show t = Identifier.show t.identifier *)
  (* let compare a b = compare (address a) (address b) *)
  (* let equal a b = compare a b = 0 *)
end

and LuaFunction : sig
  type t =
    { identifier : Identifier.t
    ; impl : Value.t list -> Value.t
    }
  [@@deriving show, ord, eq]
end = struct
  type t =
    { identifier : Identifier.t
    ; impl : Value.t list -> Value.t
    }

  (* let show *)
  let pp fmt t = Identifier.pp fmt t.identifier
  let show t = Identifier.show t.identifier
  let compare a b = compare (address a) (address b)
  let equal a b = compare a b = 0
end

and Value : sig
  type t =
    | Nil
    | Boolean of bool
    | Number of float
    | String of string
    | Table of LuaTable.t
    | Function of LuaFunction.t
    | Userdata
    | Thread
  [@@deriving show, ord, eq]
end = struct
  type t =
    | Nil
    | Boolean of bool
    | Number of float
    | String of string
    | Table of LuaTable.t
    | Function of LuaFunction.t
    | Userdata
    | Thread
  [@@deriving show { with_path = false }, ord, eq]
end

include Value

let is_truthy = function
  | Nil | Boolean false -> false
  | _ -> true
;;