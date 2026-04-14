open Ctypes

module Types (T : Ctypes.TYPE) = struct
  open T

  (** Location. *)
  type location
  let location : location structure typ = typedef (structure "fz_location") "fz_location"                                           
  let location_chapter = field location "chapter" int
  let location_page = field location "page" int
  let () = seal location

  (** Rectangle. *)
  type rect
  let rect : rect structure typ = typedef (structure "fz_rect") "fz_rect"
  let () = seal rect

  (** Matrix. *)
  type matrix
  let matrix : matrix structure typ = typedef (structure "fz_matrix") "fz_matrix"
  let () = seal matrix
end
