module Make () = struct
  module Config : Config.S = struct
    open Config
    let author =
      { name = "Shon Feder"
      ; email = "shon.feder@gmail.com"
      }
  end

  module Template = Template.Make (Config)

  let md_dir = Fpath.v "./site/md"

  let landing_page ~title service file =
    let page' () () =
      let title' = Printf.sprintf "%s's %s" Config.author.name title in
      let path = Fpath.(md_dir / file |> add_ext "md") in
      Lwt.return @@
      Template.landing_page_of_file title' path
    in
    service, page'

  let page ~title service file =
    let page' () () =
      let title' = Printf.sprintf "%s's %s" Config.author.name title in
      let path = Fpath.(md_dir / file |> add_ext "md") in
      Lwt.return @@
      Template.page_of_file title' path
    in
    service, page'

  (* TODO way to cache renders if they haven't changed pages *)
  let pages () =
    [ landing_page ~title:"Home Page" Template.home "home"
    ; page ~title:"Projects" Template.projects "projects"
    ; page ~title:"Programs" Template.programs "programs"
    ; page ~title:"Posts"    Template.posts    "posts"
    ; page ~title:"Resume"   Template.resume   "resume"
    ]

  let init () =
    ()
    |> pages
    |> List.iter begin fun (service, handler) ->
      Eliom_registration.Html.register ~service handler
    end
end

let init () =
  print_endline "Starting service registration"; (*TODO*)
  let module M = Make () in
  M.init ();
  print_endline "Services registration complete." (*TODO*)
