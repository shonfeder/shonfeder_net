module Make (C : Config.S) : sig
  module _ = C
  type page_builder = string -> Fpath.t -> Tyxml.Html.doc

  val landing_page_of_file : page_builder
  val page_of_file : page_builder
end
