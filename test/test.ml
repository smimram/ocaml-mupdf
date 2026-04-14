open Mupdf.MuPDF

let () =
  Document.register_handlers ();
  let doc = Document.open_document "test.pdf" in
  Printf.printf "Pages: %d\n%!" @@ Document.count_pages doc;
  let page = Document.load_page doc 0 in
  let rect = Page.boundary page in
  Printf.printf "rect: %.02f,%.02f x %.02f,%.02f\n%!" rect.x0 rect.y0 rect.x1 rect.y1;
  let text = Structured_text.Page.create rect in
  let dev = Structured_text.device text in
  Page.run page dev;
  Device.close dev;
  let buf = Buffer.create 1024 in
  let out = Output.with_buffer buf in
  Structured_text.Page.print_as_text out text;
  let text = Buffer.to_string buf in
  Printf.printf "Text:\n\n%s\n%!" text;
  Printf.printf "%d occurrences of `world`\n%!" (List.length @@ Page.search page "world")
