open Ctypes

(* This Types_generated module is an instantiation of the Types functor defined in the type_description.ml file. *)
module Types = Types_generated

module Functions (F : Ctypes.FOREIGN) = struct
  open F

  (** Contexts. *)

  type context = unit ptr

  let context : context typ = ptr void

  let new_context = foreign "fz_new_context" (ptr void @-> ptr void @-> int @-> returning (ptr_opt void))

  let drop_context = foreign "fz_drop_context" (context @-> returning void)

  (** Pages. *)
  type page = unit ptr

  let page : page typ = ptr void

  let page_opt : page option typ = ptr_opt void

  let drop_page = foreign "fz_drop_page" (context @-> page @-> returning void)

  (** Documents. *)
  type document = unit ptr

  let document : document typ = ptr void

  let document_opt : document option typ = ptr_opt void

  let register_document_handlers = foreign "fz_register_document_handlers" (context @-> returning void)

  let open_document = foreign "fz_open_document" (context @-> string @-> returning document_opt)

  let count_pages = foreign "fz_count_pages" (context @-> document @-> returning int)

  let load_page = foreign "fz_load_page" (context @-> document @-> int @-> returning page)
end
