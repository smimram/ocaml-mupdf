(lang dune 3.14)

(name mupdf)
(version 0.1.0)
(authors "Samuel Mimram <smimram@gmail.com>")
(maintainers "Samuel Mimram <smimram@gmail.com>")
(source (github smimram/ocaml-mupdf))
(license AGPL-3.0-or-later)

(using ctypes 0.3)
(generate_opam_files)

(package
 (name mupdf)
 (description "Bindings to the MuPDF library")
 (synopsis "Bindings to the MuPDF library in order to manipulate pdf files")
)
