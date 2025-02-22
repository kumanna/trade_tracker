(lang dune 3.10)

(name trade_tracker)

(generate_opam_files true)

(source
 (github kumanna/trade_tracker))

(authors "Kumar Appaiah")

(maintainers "Kumar Appaiah")

(license GPL-3.0-or-later)

(documentation https://github.com/kumanna/trade_tracker/blob/master/README.md)

(package
 (name trade_tracker)
 (synopsis "Trade tracker")
 (description "A barebones trade tracker to track costs incurred when executing delivery trades on Indian stock exchanges.")
 (depends ocaml dune sqlite3 ppx_jane core_unix)
 (tags
  (topics stock trade tax india)))
