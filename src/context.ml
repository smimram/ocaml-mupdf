open Ctypes

include C.Functions

include Context

let create () : t =
  let ctx =
    (* TODO: use FZ_STORE_DEFAULT *)
    let store_default = 256 lsl 20 in
    create (from_voidp void null) (from_voidp void null) store_default
  in
  (* TODO: handle errors *)
  let ctx = Option.get ctx in
  Gc.finalise drop ctx;
  ctx

(* Default context. *)
let default = create ()
