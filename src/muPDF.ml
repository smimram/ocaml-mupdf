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

  (** Identity transform matrix. *)
  let identity = !@ identity
end

module Quad = struct
  type t = {
    ul : float * float;
    ur : float * float;
    ll : float * float;
    lr : float * float;
  }

  let of_struct q =
    let xy f = let p = getf q f in (getf p Types_generated.point_x, getf p Types_generated.point_y) in
    {
      ul = xy Types_generated.quad_ul;
      ur = xy Types_generated.quad_ur;
      ll = xy Types_generated.quad_ll;
      lr = xy Types_generated.quad_lr;
    }
end

module Buffer = struct
  type t = buffer

  let create len =
    let buf = new_buffer ctx len in
    Gc.finalise (drop_buffer ctx) buf;
    buf

  (** Zero-terminate buffer in order to use as a C string. *)
  let terminate buf = terminate_buffer ctx buf

  (** String contents of a buffer. *)
  let to_string buf = string_from_buffer ctx buf
end

module Output = struct
  type t = output

  (** Output to a buffer. *)
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

    (** Print a page as text. *)
    let print_as_text out page = print_stext_page_as_text ctx out page
  end

  let device page =
    let dev = new_stext_device ctx page None in
    Gc.finalise (drop_device ctx) dev;
    dev
end

module Page = struct
  type t = page

  (** Determine the size of a page at 72 dpi. *)
  let boundary page : Rectangle.t = Rectangle.of_struct @@ bound_page ctx page

  (** Run a page through a device. *)
  let run ?(transform=Matrix.identity) page dev = run_page ctx page dev transform None

  (** String representation of the contents of the page. *)
  let get_text page =
    let text = Structured_text.Page.create @@ boundary page in
    let dev = Structured_text.device text in
    run page dev;
    Device.close dev;
    let buf = Buffer.create 1024 in
    let out = Output.with_buffer buf in
    Structured_text.Page.print_as_text out text;
    Buffer.to_string buf

  (** Search for needle in a page. Returns the list of matching quad bounding boxes. *)
  let search ?(max_hits=50) page needle =
    let hits = CArray.make Types_generated.quad max_hits in
    let n = search_page ctx page needle None (CArray.start hits) max_hits in
    List.init n (fun i -> Quad.of_struct (CArray.get hits i))
end

module Document = struct
  type t = document

  (** Register handlers for all the standard document types supported in this build. *)
  let register_handlers () = register_document_handlers ctx

  (** Open a document file and read its basic structure so pages and objects can be located. MuPDF will try to repair broken documents (without actually changing the file contents). *)
  let open_document fname = Option.get @@ open_document ctx fname

  (** Return the number of pages in document. *)
  let count_pages doc = count_pages ctx doc

  (** Load a given page number from a document. This may be much less efficient than loading by location (chapter+page) for some document types. *)
  let load_page doc n =
    let page = load_page ctx doc n in
    Gc.finalise (drop_page ctx) page;
    page

  (** Get the location for the last page in the document. Using this can be far more efficient in some cases than calling count_pages and using the page number. *)
  let last_page doc = last_page ctx doc
end
