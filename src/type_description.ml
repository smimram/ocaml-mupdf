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
  let rect_x0 = field rect "x0" float
  let rect_y0 = field rect "y0" float
  let rect_x1 = field rect "x1" float
  let rect_y1 = field rect "y1" float
  let () = seal rect

  (** Matrix. *)
  type matrix
  let matrix : matrix structure typ = typedef (structure "fz_matrix") "fz_matrix"
  let matrix_a = field matrix "a" float
  let matrix_b = field matrix "b" float
  let matrix_c = field matrix "c" float
  let matrix_d = field matrix "d" float
  let matrix_e = field matrix "e" float
  let matrix_f = field matrix "f" float
  let () = seal matrix

  (** Point. *)
  type point
  let point : point structure typ = typedef (structure "fz_point") "fz_point"
  let point_x = field point "x" float
  let point_y = field point "y" float
  let () = seal point

  (** Quad (quadrilateral with upper-left, upper-right, lower-left, lower-right corners). *)
  type quad
  let quad : quad structure typ = typedef (structure "fz_quad") "fz_quad"
  let quad_ul = field quad "ul" point
  let quad_ur = field quad "ur" point
  let quad_ll = field quad "ll" point
  let quad_lr = field quad "lr" point
  let () = seal quad
end
