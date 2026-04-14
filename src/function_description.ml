open Ctypes

(* This Types_generated module is an instantiation of the Types functor defined in the type_description.ml file. *)
module Types = Types_generated

module Functions (F : Ctypes.FOREIGN) = struct
  open F

  type context = unit ptr

  let context : context typ = ptr void

  module Context = struct
    type t = context

    let t = context

    let create = foreign "fz_new_context" (ptr void @-> ptr void @-> int @-> returning (ptr_opt void))

    let drop = foreign "fz_drop_context" (t @-> returning void)
  end

  module PDF = struct
    type t = unit ptr

    let t : t typ = ptr void

    let open_document = foreign "pdf_open_document" (context @-> string @-> returning t)
  end
end
