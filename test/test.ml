open Mupdf.MuPDF

let () =
  Document.register_handlers ();
  let doc = Document.open_document "test.pdf" in
  Printf.printf "Pages: %d\n%!" @@ Document.count_pages doc;
  let page = Document.load_page doc 0 in
  let text = Structured_text.Page.create @@ Page.boundary page in
  let dev = Device.stext text in
  Page.run page dev
