(** Main module containing all the MuPDF bindings. *)

(**/**)
open Ctypes

include C.Functions
(**/**)

(** MuPDF computation contexts. *)
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

(**/**)
let ctx = Context.create ()
(**/**)

(** Points. *)
module Point = struct
  (** A point. *)
  type t = float * float

  (**/**)
  let of_struct p : t =
    (getf p Types_generated.point_x, getf p Types_generated.point_y)

  let to_struct (x,y) =
    let p = make Types_generated.point in
    setf p Types_generated.point_x x;
    setf p Types_generated.point_y y;
    p
  (**/**)
end

(** Rectangles. *)
module Rectangle = struct
  (** A rectangle. *)
  type t = {
      x0 : float;
      y0 : float;
      x1 : float;
      y1 : float;
    }

  (**/**)
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
  (**/**)
end

(** Quadrangles. *)
module Quad = struct
  (** A representation for a region defined by 4 points. The significant difference between quads and rects is that the edges of quads are not axis aligned. *)
  type t =
    {
      ul : Point.t; (** upper-left corner *)
      ur : Point.t; (** upper-right corner *)
      ll : Point.t; (** lower-left corner *)
      lr : Point.t; (** lower-right corner *)
    }

  (**/**)
  let of_struct q =
    let xy f =
      Point.of_struct @@ getf q f
    in
    {
      ul = xy Types_generated.quad_ul;
      ur = xy Types_generated.quad_ur;
      ll = xy Types_generated.quad_ll;
      lr = xy Types_generated.quad_lr;
    }

  let to_struct q =
    let s = make Types_generated.quad in
    setf s Types_generated.quad_ul @@ Point.to_struct q.ul;
    setf s Types_generated.quad_ur @@ Point.to_struct q.ur;
    setf s Types_generated.quad_ll @@ Point.to_struct q.ll;
    setf s Types_generated.quad_lr @@ Point.to_struct q.lr;
    s
  (**/**)
end

(** Matrices. *)
module Matrix = struct
  (** A transform matrix. *)
  type t = (matrix, [`Struct]) structured

  (** Identity transform matrix. *)
  let identity : t =
    let m = make Types_generated.matrix in
    setf m Types_generated.matrix_a 1.0;
    setf m Types_generated.matrix_b 0.0;
    setf m Types_generated.matrix_c 0.0;
    setf m Types_generated.matrix_d 1.0;
    setf m Types_generated.matrix_e 0.0;
    setf m Types_generated.matrix_f 0.0;
    m
end

(** Buffers. *)
module Buffer = struct
  (** A buffer. *)
  type t = buffer

  (** Create a buffer. *)
  let create len : t =
    let buf = new_buffer ctx len in
    Gc.finalise (drop_buffer ctx) buf;
    buf

  (** Zero-terminate buffer in order to use as a C string. *)
  let terminate buf : unit = terminate_buffer ctx buf

  (** String contents of a buffer. *)
  let to_string buf : string = string_from_buffer ctx buf
end

(** Outputs. *)
module Output = struct
  type t = output

  (** Flush pending output and close an output stream. *)
  let close out : unit = close_output ctx out

  (** Output to a buffer. *)
  let with_buffer buf : output =
    let out = new_output_with_buffer ctx buf in
    Gc.finalise (drop_output ctx) out;
    out
end

(** Devices. *)
module Device = struct
  type t = device

  let close dev : unit =
    close_device ctx dev
end

(** Structured text. *)
module Structured_text = struct
  module Page = struct
    type t = stext_page

    let create box : t =
      let page = new_stext_page ctx (Rectangle.to_struct box) in
      Gc.finalise (drop_stext_page ctx) page;
      page

    (** Print a page as text. *)
    let print_as_text out page : unit = print_stext_page_as_text ctx out page
  end

  let device page : Device.t =
    let dev = new_stext_device ctx page None in
    Gc.finalise (drop_device ctx) dev;
    dev
end

(** Pages. *)
module Page = struct
  (** A page. *)
  type t = page

  (** Determine the size of a page at 72 dpi. *)
  let boundary page : Rectangle.t = Rectangle.of_struct @@ bound_page ctx page

  (** Run a page through a device. *)
  let run ?(transform=Matrix.identity) page dev : unit = run_page ctx page dev transform None

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

(** Documents. *)
module Document = struct
  (** A document. *)
  type t = document

  (** Register handlers for all the standard document types supported in this build. *)
  let register_handlers () : unit = register_document_handlers ctx

  (** Open a document file and read its basic structure so pages and objects can be located. MuPDF will try to repair broken documents (without actually changing the file contents). *)
  let open_document fname : t = Option.get @@ open_document ctx fname

  let close doc : unit = drop_document ctx doc

  (** Return the number of pages in document. *)
  let count_pages doc : int = count_pages ctx doc

  (** Load a given page number from a document. This may be much less efficient than loading by location (chapter+page) for some document types. *)
  let load_page doc n : Page.t =
    let page = load_page ctx doc n in
    Gc.finalise (drop_page ctx) page;
    page

  (** All pages of the document. *)
  let pages doc = List.init (count_pages doc) (load_page doc)

  (** Get the location for the last page in the document. Using this can be far more efficient in some cases than calling count_pages and using the page number. *)
  let last_page doc = last_page ctx doc

  (** Number of chapters in the document. *)
  let count_chapters doc : int = count_chapters ctx doc
end

(** High-level interface for pdf manipulation. *)
module PDF = struct
  module Document = struct
    type t = PDF.document

    let create () : t = PDF.create_document ctx

    (** Close document. *)
    let close doc : unit = PDF.drop_document ctx doc

    (** Write out the document to a file with all changes finalised. *)
    let save (doc:t) fname : unit =
      PDF.save_document ctx doc fname None

    let count_pages (doc:t) : int =
      PDF.count_pages ctx doc

    (** Graft a page (and its resources) from the src document to the destination document of the graft. This involves a deep copy of the objects in question. *)
    let graft_pages (dst:t) page_to (src:t) page_from : unit =
      PDF.graft_page ctx dst page_to src page_from
  end
end
