open Ctypes

module Types (T : Ctypes.TYPE) = struct
  (* open T *)

  module Context = struct
    type t = unit ptr  
  end
end
