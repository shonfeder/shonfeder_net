module Service = Eliom_service
module Param = Eliom_parameter

module Make (Config : Config.S) = struct
  (* With reference to https://ocaml.org/cookbook/get-todays-date/stdlib *)
  let current_year () =
    ()
    |> Unix.time
    |> Unix.localtime
    |> (fun {tm_year; _} -> tm_year + 1900)
    |> Int.to_string

  (* A page is a simple service that takes no parameters. *)
  type page = (unit, unit, Service.get, Service.att, Service.non_co, Service.non_ext,
               Service.reg, [ `WithoutSuffix ], unit, unit, Service.non_ocaml) Service.t

  type page_service =
    { title : string
    ; name: string
    ; service: page
    }

  open Eliom_content.Html.D

  (* Helpers *)
  let extern ?(path=[]) base = Service.(extern ~prefix:base ~path ~meth:(Get Param.unit)  ())
  let asset path = make_uri ~service:(Service.static_dir ()) path

  (* A simple service, serving a page *)
  let simple title name =
    { name
    ; title
    ; service = Service.(create ~name ~path:(Path [name]) ~meth:(Get Param.unit) ())
    }

  let home     =
    { title = "Home Page"
    ; name = "home"
    ; service = Service.(create ~name:"home" ~path:(Path []) ~meth:(Get Param.unit) ())
    }
  let projects = simple "Projects" "projects"
  let programs = simple "Programs" "programs"
  let posts    = simple "Posts" "posts"
  let resume   = simple "Resume" "resume"

  let sub_pages =
    [ projects
    ; programs
    ; posts
    ; resume
    ]

  let logo ~current =
    let classes = if current then ["current"] else [] in
    a ~service:home.service
      [img
         ~a:[a_id "logo"; a_class classes]
         ~alt:"Synechist Logo"
         ~src:(asset ["media"; "logo.png"])
         ()]
      ()

  let nav page_id =
    let link {service; name; _} =
      let class_ = if String.equal name page_id then ["current"] else [] in
      a ~service ~a:[a_class class_] [txt name] ()
    in
    nav [ul (List.map (fun p -> li [link p]) sub_pages)]

  let banner content = div ~a:[a_id "banner"] content

  let landing_header page_id =
    let author = h1 ~a:[a_id "author-title"] [txt Config.author.name] in
    header ~a:[a_id "header"] [banner [logo ~current:true; author]; nav page_id;]

  let default_header page_id =
    header ~a:[a_id "header"] [banner [logo ~current:false]; nav page_id]

  (* External services *)
  let social_presence_links () =
    let link ~base ~path ~alt ~title ~src =
      let src = asset src in
      a
        ~service:(extern base ~path)
        ~a:[a_title title; a_target "_blank"]
        [img ~a:[a_class ["social-media-link"]] ~alt ~src ()]
        ()
    in
    let links =
      [ link
          ~base:"https://github.com"
          ~path:["shonfeder"]
          ~title:"Github Profile"
          ~src:["media"; "github-logo.png"]
          ~alt:"GitHub logo"
          ;
        link
          ~base:"http://stackoverflow.com"
          ~path:["users"; "1187277"; "shon-feder"]
          ~title:"StackOverflow Profile"
          ~src:["media"; "stackoverflow-logo.png"]
          ~alt:"StackOverflow logo";
        link
          ~base:"https://www.linkedin.com/"
          ~path:["in"; "shonfeder"]
          ~title:"LinkedIn Profile"
          ~src:["media"; "linkedin-logo.png"]
          ~alt:"LinkedIn Logo";
        link
          ~base:"https://en.wikipedia.org/"
          ~path:["wiki"; "User:Shonfeder"]
          ~title:"Wikipedia Profile"
          ~src:["media"; "wikipedia-logo.png"]
          ~alt:"Wikipedia Logo";
        link
          ~base:"mailto:shon.feder@gmail.com?Subject=Making+Contact"
          ~path:[]
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
               ; a_style "border-width:0;width:4em"]
            ~alt:"Creative Commons BY-SA License"
            ~src:(asset ["media"; "cc-by-sa.png"] )
            ()]
        ()
    in
    let cc_notice = li ~a:[a_id "cc-notice"] [cc] in
    let year = li ~a:[a_class ["current-year"]] [txt ("2016 - " ^ current_year ())] in
    let author = li ~a:[a_class ["author-name"]] [txt Config.author.name] in
    let powered_by =
      let link = a ~service:(extern "https://ocsigen.org") [txt "ocsigen"] () in
      li ~a:[a_id "built-with"] [txt "Built with "; link]
    in
    ul ~a:[a_id "signature"]
      [ author
      ; year
      ; cc_notice
      ; powered_by
      ]

  let footer' () =
    footer ~a:[a_id "footer"]
      [ div ~a:[a_class ["footer-content"]]
          [ social_presence_links ()
          ; signature ()]
      ]

  let main_section content =
    section ~a:[a_class ["main"]] content

  let head' title' =
    let title' = Printf.sprintf "%s's %s" Config.author.name title' in
    head (title (txt title'))
      [ css_link ~uri:(asset ["styles"; "style.css"]) ()
      ; js_script ~uri:(asset ["js"; "script.js"]) ()
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

  let html_of_md_file = fun path ->
    Logs.info (fun f -> f "Loading file from disk %a" Fpath.pp path);
    In_channel.input_all
    |> In_channel.with_open_text (Fpath.to_string path)
    |> Cmarkit.Doc.of_string
    |> Cmarkit_html.of_doc ~safe:false
    |> fun x -> (Unsafe.data x)

  let fpath =
    let md_dir = Fpath.v "./site/md" in
    fun name -> Fpath.(md_dir / name |> add_ext "md")

  let landing_page_of_file {title; name; _} =
    let content = html_of_md_file (fpath name) in
    landing_page name title [content]

  let page_of_file {title; name; _} =
    let content = html_of_md_file (fpath name) in
    page name title [content]

  let contentes =
    let tbl = Hashtbl.create 5 in
    let add_page handler service = Hashtbl.add tbl service.name (lazy (handler service)) in
    add_page landing_page_of_file home;
    List.iter (add_page page_of_file) sub_pages;
    tbl

  let register_page {service; name; _} =
    Eliom_registration.Html.register ~service begin
      fun () () ->
        Lwt.return @@ Lazy.force @@ Hashtbl.find contentes name
    end

  let () =
    Logs.info (fun f -> f "Starting service registration");
    List.iter register_page (home :: sub_pages);
    Logs.info (fun f -> f "Service registration complete")
end
