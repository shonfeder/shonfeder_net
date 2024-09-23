module Service = Eliom_service
module Param = Eliom_parameter

type page =
  (unit, unit, Service.get, Service.att, Service.non_co, Service.non_ext,
   Service.reg, [ `WithoutSuffix ], unit, unit, Service.non_ocaml)
    Service.t

module Make (Config : Config.S) = struct
  (* With reference to https://ocaml.org/cookbook/get-todays-date/stdlib *)
  let current_year () =
    ()
    |> Unix.time
    |> Unix.localtime
    |> (fun {tm_year; _} -> tm_year + 1900)
    |> Int.to_string

  open Eliom_content.Html.D

  (* Helpers *)
  let extern url = Service.(extern ~prefix:url ~path:[] ~meth:(Get Param.unit)  ())
  let simple name = Service.(create ~name ~path:(Path [name]) ~meth:(Get Param.unit) ())
  let uri path = make_uri ~service:(Service.static_dir ()) path
  let extern_uri url = make_uri ~service:(extern url) ()

  (* Services *)
  let home     = Service.(create ~name:"home" ~path:(Path []) ~meth:(Get Param.unit) ())
  let projects = simple "projects"
  let programs = simple "programs"
  let posts    = simple "posts"
  let resume   = simple "resume"

  let logo ~current =
    let classes = if current then ["current"] else [] in
    a ~service:home
      [img
         ~a:[a_id "logo"; a_class classes]
         ~alt:"Synechist Logo"
         ~src:(uri ["media"; "logo.png"])
         ()]
      ()

  let nav page_id =
    let link service name =
      let class_ = if String.equal name page_id then ["current"] else [] in
      a ~service ~a:[a_class class_] [txt name] () in
    let links =
      [ link projects "projects"
      ; link programs "programs"
      ; link posts "posts"
      ; link resume "resume"
      ]
    in
    nav [ul (ListLabels.map ~f:(fun i -> li [i]) links)]

  let banner content = div ~a:[a_id "banner"] content

  let landing_header page_id =
    let author = h1 ~a:[a_id "author-title"] [txt Config.author.name] in
    header ~a:[a_id "header"] [banner [logo ~current:true; author]; nav page_id;]

  let default_header page_id =
    header ~a:[a_id "header"] [banner [logo ~current:false]; nav page_id]

  (* External services *)
  let social_presence_links () =
    let link ~alt ~title ~src url =
      let src = uri src in
      a
        ~service:(extern url)
        ~a:[a_title title; a_target "_blank"]
        [img ~a:[a_class ["social-media-link"]] ~alt ~src ()]
        ()
    in
    let links =
      [ link "https://github.com/shonfeder"
          ~title:"Github Profile"
          ~src:["media"; "github-logo.png"]
          ~alt:"GitHub logo";
        link "http://stackoverflow.com/users/1187277/shon-feder"
          ~title:"StackOverflow Profile"
          ~src:["media"; "stackoverflow-logo.png"]
          ~alt:"StackOverflow logo";
        link "https://www.linkedin.com/in/shonfeder"
          ~title:"LinkedIn Profile"
          ~src:["media"; "linkedin-logo.png"]
          ~alt:"LinkedIn Logo";
        link "https://en.wikipedia.org/wiki/User:Shonfeder"
          ~title:"Wikipedia Profile"
          ~src:["media"; "wikipedia-logo.png"]
          ~alt:"Wikipedia Logo";
        link "mailto:shon.feder@gmail.com?Subject=Making+Contact"
          ~title:"Email Me"
          ~src:["media"; "email-logo.png"]
          ~alt:"Email Icon";
      ]
    in
    ul ~a:[a_class ["digital-presence"]]
      (ListLabels.map ~f:(fun l -> li [l]) links)

  let signature () =
    let cc = a
        ~a:[a_rel [`License]]
        ~service:(extern "https://creativecommons.org/licenses/by-sa/4.0")
        [ img
            ~a:[ a_title "This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License"
               ; a_style "border-width:0"]
            ~alt:"Creative Commons License"
            ~src:(extern_uri "https://i.creativecommons.org/l/by-sa/4.0/80x15.png")
            ()]
        ()
    in
    let cc_notice = li ~a:[a_id "cc-notice"] [cc] in
    let year = li ~a:[a_class ["current-year"]] [txt ("2016 - " ^ current_year ())] in
    let author = li ~a:[a_class ["author-name"]] [txt Config.author.name] in
    let powered_by =
      let link = a ~service:(extern "https://ocsigen.org") [txt "ocsigen"] () in
      li ~a:[a_id "built-with"] [txt "Built with by "; link]
    in
    ul ~a:[a_id "signature"]
      [ author
      ; year
      ; cc_notice
      ; powered_by ]

  let footer' () =
    footer ~a:[a_id "footer"]
      [ div ~a:[a_class ["footer-content"]]
          [ social_presence_links ()
          ; signature ()]
      ]

  let main_section content =
    section ~a:[a_class ["main"]] content

  let head' title' =
    head (title (txt title'))
      [ css_link ~uri:(uri ["styles"; "style.css"]) ()
      ; js_script ~uri:(uri ["js"; "script.js"]) ()
      ; meta ~a:[a_charset "utf-8"] ()
      ; meta ~a:[a_name "viewport"; a_content "width=device-width, initial-scale=1"] ()
      ]

  let body' header' content =
    body [ header'
         ; main_section content
         ; footer' ()
         ]

  let page page_id title' content =
    let header = default_header page_id in
    html (head' title') (body' header content)

  let landing_page page_id title' content =
    let header = landing_header page_id in
    html (head' title') (body' header content)

  type page_builder = string -> Fpath.t -> doc

  let page_id_of_fpath path =
    Fpath.(base path |> rem_ext |> to_string)

  let html_of_md_file = fun path ->
    In_channel.input_all
    |> In_channel.with_open_text (Fpath.to_string path)
    |> Cmarkit.Doc.of_string
    |> Cmarkit_html.of_doc ~safe:false
    |> fun x -> (Unsafe.data x)

  let landing_page_of_file : page_builder =
    fun title file ->
    let page_id = page_id_of_fpath file in
    let content = html_of_md_file file in
    landing_page page_id title [content]

  let page_of_file : page_builder =
    fun title file ->
    let page_id = page_id_of_fpath file in
    let content = html_of_md_file file in
    page page_id title [content]

end
