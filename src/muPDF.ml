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

module Rectangle = struct
  type t = {
      x0 : float;
      y0 : float;
      x1 : float;
      y1 : float;
    }

  let of_struct x =
    {
      x0 = getf x Types_generated.rect_x0;
      y0 = getf x Types_generated.rect_y0;
      x1 = getf x Types_generated.rect_x1;
      y1 = getf x Types_generated.rect_y1;
    }

  let to_struct r =
    let s = make Types_generated.rect in
    setf s Types_generated.rect_x0 r.x0;
    setf s Types_generated.rect_y0 r.y0;
    setf s Types_generated.rect_x1 r.x1;
    setf s Types_generated.rect_y1 r.y1;
    s
end

module Matrix = struct
  type t = matrix

  let identity = !@ identity
end

module Buffer = struct
  type t = buffer

  let create len =
    let buf = new_buffer ctx len in
    Gc.finalise (drop_buffer ctx) buf;
    buf

  let terminate buf = terminate_buffer ctx buf

  let to_string buf = string_from_buffer ctx buf
end

module Output = struct
  type t = output

  let with_buffer buf =
    let out = new_output_with_buffer ctx buf in
    Gc.finalise (drop_output ctx) out;
    out
end

module Device = struct
  type t = device

  let close dev =
    close_device ctx dev
end

module Structured_text = struct
  module Page = struct
    type t = stext_page

    let create box = new_stext_page ctx (Rectangle.to_struct box)

    let print_as_text out page = print_stext_page_as_text ctx out page
  end

  let device page =
    let dev = new_stext_device ctx page None in
    Gc.finalise (drop_device ctx) dev;
    dev
end

module Page = struct
  type t = page

  let boundary page : Rectangle.t = Rectangle.of_struct @@ bound_page ctx page

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
