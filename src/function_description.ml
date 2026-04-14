open Ctypes

(* This Types_generated module is an instantiation of the Types functor defined in the type_description.ml file. *)
module Types = Types_generated

module Functions (F : Ctypes.FOREIGN) = struct
  open Types
  open F

  (** Contexts. *)
  type context = unit ptr
  let context : context typ = ptr void
  let new_context = foreign "fz_new_context" (ptr void @-> ptr void @-> int @-> returning (ptr_opt void))
  let drop_context = foreign "fz_drop_context" (context @-> returning void)

  (** Matrices. *)
  type matrix = Types.matrix

  (** Buffers. *)
  type buffer = unit ptr
  let buffer : buffer typ = ptr void
  let drop_buffer = foreign "fz_drop_buffer" (context @-> buffer @-> returning void)
  let new_buffer = foreign "fz_new_buffer" (context @-> int @-> returning buffer)
  let terminate_buffer = foreign "fz_terminate_buffer" (context @-> buffer @-> returning void)
  let string_from_buffer = foreign "fz_string_from_buffer" (context @-> buffer @-> returning string)

  (** Outputs. *)
  type output = unit ptr
  let output : output typ = ptr void
  let drop_output = foreign "fz_drop_output" (context @-> output @-> returning void)
  let new_output_with_buffer = foreign "fz_new_output_with_buffer" (context @-> buffer @-> returning output)

  (** Cookies. *)
  type cookie = unit ptr
  let cookie : cookie typ = ptr void
  let cookie_opt : cookie option typ = ptr_opt void

  (** Devices. *)
  type device = unit ptr
  let device : device typ = ptr void
  let close_device = foreign "fz_close_device" (context @-> device @-> returning void)
  let drop_device = foreign "fz_drop_device" (context @-> device @-> returning void)

  type stext_page = unit ptr
  let stext_page : stext_page typ = ptr void
  let new_stext_page = foreign "fz_new_stext_page" (context @-> rect @-> returning stext_page)
  let drop_stext_page = foreign "fz_drop_stext_page" (context @-> stext_page @-> returning void)
  let new_stext_device = foreign "fz_new_stext_device" (context @-> stext_page @-> ptr_opt void @-> returning device)
  let print_stext_page_as_text = foreign "fz_print_stext_page_as_text" (context @-> output @-> stext_page @-> returning void)

  (** Pages. *)
  type page = unit ptr
  let page : page typ = ptr void
  let page_opt : page option typ = ptr_opt void
  let drop_page = foreign "fz_drop_page" (context @-> page @-> returning void)
  let bound_page = foreign "fz_bound_page" (context @-> page @-> returning rect)
  let run_page = foreign "fz_run_page" (context @-> page @-> device @-> matrix @-> cookie_opt @-> returning void)
  let search_page = foreign "fz_search_page" (context @-> page @-> string @-> ptr_opt int @-> ptr quad @-> int @-> returning int)

  (** Documents. *)
  type document = unit ptr
  let document : document typ = ptr void
  let document_opt : document option typ = ptr_opt void
  let register_document_handlers = foreign "fz_register_document_handlers" (context @-> returning void)
  let open_document = foreign "fz_open_document" (context @-> string @-> returning document_opt)
  let count_pages = foreign "fz_count_pages" (context @-> document @-> returning int)
  let load_page = foreign "fz_load_page" (context @-> document @-> int @-> returning page)
  let last_page = foreign "fz_last_page" (context @-> document @-> returning location)
  let count_chapters = foreign "fz_count_chapters" (context @-> document @-> returning int)

  module PDF = struct
    type document = unit ptr
    let document : document typ = ptr void
    let create_document = foreign "pdf_create_document" (context @-> returning document)
    let drop_document = foreign "pdf_drop_document" (context @-> document @-> returning void)
    let count_pages = foreign "pdf_count_pages" (context @-> document @-> returning int)
    let graft_page = foreign "pdf_graft_page" (context @-> document @-> int @-> document @-> int @-> returning void)
    let save_document = foreign "pdf_save_document" (context @-> document @-> string @-> ptr_opt void @-> returning void)
  end
end

(**/**)
