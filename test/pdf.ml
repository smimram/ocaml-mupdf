(** Basic manipulation of pages in a pdf. *)

open MuPDF

let () =
  let input  = PDF.Document.open_document "test.pdf" in
  let output = PDF.Document.create () in
  PDF.Document.graft_page output 0 input 0;
  PDF.Document.graft_page output 1 input 0;
  PDF.Document.graft_page output 2 input 0;
  PDF.Document.delete_page output 1;
  PDF.Document.save output "output.pdf"
