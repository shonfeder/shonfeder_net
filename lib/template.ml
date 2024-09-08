open! Core
open Tyxml

module Make (Config : Config.S) = struct
  let current_year () = Time_float.(now () |> to_date ~zone:Zone.utc |> Date.year |> Int.to_string)

  type 'a fill =
    { content: 'a Html.elt
    ; title: string
    }
  open Html

  let logo ~current =
    let classes = if current then ["current"] else [] in
    a ~a:[a_href "/"]
      [img ~a:[a_id "logo"; a_class classes]
         ~alt:"Synechist Logo"
         ~src:"/media/indescriptum-logo.png" ()]

  let nav page_id =
    let link dest =
      let class_ = if String.equal dest page_id then ["current"] else [] in
      a ~a:[a_href ("/" ^ dest); a_class class_] [txt dest] in
    let links =
      [ link "programs"
      ; link "projects"
      ; link "posts"
      ; link "resume"
      ]
    in
    nav [ul (List.map ~f:(fun i -> li [i]) links)]

  let banner content = div ~a:[a_id "banner"] content

  let landing_header page_id =
    let author = h1 ~a:[a_id "author-title"] [txt Config.author.name] in
    header ~a:[a_id "header"] [banner [logo ~current:true; author]; nav page_id;]

  let default_header page_id =
    header ~a:[a_id "header"] [banner [logo ~current:false]; nav page_id]

  let social_presence_links =
    let link ~alt ~title ~src href =
      a ~a:[a_href href; a_title title; a_target "_blank"] [img ~a:[a_class ["social-media-link"]] ~alt ~src ()]
    in
    let links =
      [ link "https://github.com/shonfeder"
          ~title:"Github Profile"
          ~src:"/media/github-logo.png"
          ~alt:"GitHub logo";
        link "http://stackoverflow.com/users/1187277/shon-feder"
          ~title:"StackOverflow Profile"
          ~src:"/media/stackoverflow-logo.png"
          ~alt:"StackOverflow logo";
        link "https://www.linkedin.com/in/shonfeder"
          ~title:"LinkedIn Profile"
          ~src:"/media/linkedin-logo.png"
          ~alt:"LinkedIn Logo";
        link "https://en.wikipedia.org/wiki/User:Shonfeder"
          ~title:"Wikipedia Profile"
          ~src:"/media/wikipedia-logo.png"
          ~alt:"Wikipedia Logo";
        link "mailto:shon.feder@gmail.com?Subject=Making+Contact"
          ~title:"Email Me"
          ~src:"/media/email-logo.png"
          ~alt:"Email Icon";
      ]
    in
    ul ~a:[a_class ["digital-presence"]]
      (List.map ~f:(fun l -> li [l]) links)

  let signature =
    let%html cc_html =
      {|<a rel="license"
           href="http://creativecommons.org/licenses/by-sa/4.0/">
        <img alt="Creative Commons License"
             title="This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License"
             style="border-width:0"
             src="https://i.creativecommons.org/l/by-sa/4.0/80x15.png" /></a>
      |} in
    let cc_notice = li ~a:[a_id "cc-notice"] [cc_html] in
    let year = li ~a:[a_class ["current-year"]] [txt (current_year ())] in
    let author = li ~a:[a_class ["author-name"]] [txt Config.author.name] in
    let powered_by =
      let link = a ~a:[a_href "https://github.com/rgrinberg/opium"] [txt "Opium"] in
      li ~a:[a_id "powered-by"] [txt "Powered by "; link]
    in
    ul ~a:[a_id "signature"]
      [ author
      ; year
      ; cc_notice
      ; powered_by ]

  let footer' =
    footer ~a:[a_id "footer"]
      [ div ~a:[a_class ["footer-content"]]
          [ social_presence_links
          ; signature]
      ]

  let main_section content =
    section ~a:[a_class ["main"]] content

  let head' title' =
    let script =
      script ~a:[ a_src "/js/script.js" ] (txt "")
    in
    head (title (txt title'))
      [ link ~rel:[`Stylesheet] ~href:"/styles/style.css" ()
      ; script
      ; meta ~a:[a_charset "utf-8"] ()
      ; meta ~a:[a_name "viewport"; a_content "width=device-width, initial-scale=1"] ()
      ]

  let body' header' content =
    body [ header'
         ; main_section content
         ; footer'
         ]

  let page page_id title' content =
    let header = default_header page_id in
    html (head' title') (body' header content)

  let landing_page page_id title' content =
    let header = landing_header page_id in
    html (head' title') (body' header content)

  type 'a page_builder = string -> Fpath.t -> 'a Tyxml_html.elt

  let page_id_of_fpath path =
    Fpath.(base path |> rem_ext |> to_string)

  let landing_page_of_file : _ page_builder =
    fun title file ->
    let page_id = page_id_of_fpath file in
    let content = Html_utils.of_md_file file in
    landing_page page_id title [content]

  let page_of_file : _ page_builder =
    fun title file ->
    let page_id = page_id_of_fpath file in
    let content = Html_utils.of_md_file file in
    page page_id title [content]

end
