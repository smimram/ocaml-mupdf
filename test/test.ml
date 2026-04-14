open Mupdf.MuPDF

let () =
  Document.register_handlers ();
  let doc = Document.open_document "test.pdf" in
  Printf.printf "Pages: %d\n%!" @@ Document.count_pages doc;
  let _page = Document.load_page doc 0 in
  ()
