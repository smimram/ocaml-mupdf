(* open Ctypes *)

(* This Types_generated module is an instantiation of the Types functor defined in the type_description.ml file. *)
module Types = Types_generated

module Functions (F : Ctypes.FOREIGN) = struct
  (* open F *)

  module Context = struct
    include Types.Context
  end
end
