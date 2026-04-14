open Ctypes

module Types (T : Ctypes.TYPE) = struct
  open T

  (** Location. *)
  type location
  let location : location structure typ = typedef (structure "fz_location") "fz_location"                                           
  let location_chapter = field location "chapter" int
  let location_page = field location "page" int
  let () = seal location
end
