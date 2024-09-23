module Service = Eliom_service

type page =
  (unit, unit, Service.get, Service.att, Service.non_co, Service.non_ext,
   Service.reg, [ `WithoutSuffix ], unit, unit, Service.non_ocaml)
    Service.t

module Make (C : Config.S) : sig
  module _ = C

  val home     : page
  val projects : page
  val programs : page
  val posts    : page
  val resume   : page

  type page_builder = string -> Fpath.t -> Eliom_content.Html.D.doc

  val landing_page_of_file : page_builder
  val page_of_file : page_builder
end
