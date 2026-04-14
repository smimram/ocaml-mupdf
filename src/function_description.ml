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
  type nonrec matrix = matrix
  let identity = F.foreign_value "fz_identity" matrix

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

  (** Pages. *)
  type page = unit ptr
  let page : page typ = ptr void
  let page_opt : page option typ = ptr_opt void

  let drop_page = foreign "fz_drop_page" (context @-> page @-> returning void)

  let bound_page = foreign "fz_bound_page" (context @-> page @-> returning rect)

  let run_page = foreign "fz_run_page" (context @-> page @-> device @-> matrix @-> cookie_opt @-> returning void)

  (** Documents. *)
  type document = unit ptr

  let document : document typ = ptr void

  let document_opt : document option typ = ptr_opt void

  let register_document_handlers = foreign "fz_register_document_handlers" (context @-> returning void)

  let open_document = foreign "fz_open_document" (context @-> string @-> returning document_opt)

  let count_pages = foreign "fz_count_pages" (context @-> document @-> returning int)

  let load_page = foreign "fz_load_page" (context @-> document @-> int @-> returning page)

  let last_page = foreign "fz_last_page" (context @-> document @-> returning location)
end
