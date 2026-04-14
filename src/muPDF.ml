open Ctypes

include C.Functions

module Context = struct
  type t = context

  let create () : t =
    let ctx =
      (* TODO: use FZ_STORE_DEFAULT *)
      let store_default = 256 lsl 20 in
      new_context (from_voidp void null) (from_voidp void null) store_default
    in
    (* TODO: handle errors *)
    let ctx = Option.get ctx in
    Gc.finalise drop_context ctx;
    ctx

  (* Default context. *)
  let default = create ()
end

let ctx = Context.create ()

module Matrix = struct
  type t = matrix

  let identity = !@ identity
end

module Device = struct
  let close dev =
    close_device ctx dev

  let stext page =
    let dev = new_stext_device ctx page None in
    Gc.finalise (drop_device ctx) dev;
    ctx
end

module Page = struct
  type t = page

  let run page ?(transform=Matrix.identity) dev = run_page ctx page dev transform None
end

module Document = struct
  type t = document

  let register_handlers () = register_document_handlers ctx

  let open_document fname = Option.get @@ open_document ctx fname

  let count_pages doc = count_pages ctx doc

  let load_page doc n =
    let page = load_page ctx doc n in
    Gc.finalise (drop_page ctx) page;
    page

  (* let last_page doc = last_page ctx doc *)
end
