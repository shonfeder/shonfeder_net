module Config : Config.S = struct
  open Config
  let author =
    { name = "Shon Feder"
    ; email = "shon.feder@gmail.com"
    }
end

module Template = Template.Make (Config)

let md_dir = Fpath.v "./site/md"

let landing_page ~title file =
  let route = "/" in
  let page' () =
    let title' = Printf.sprintf "%s's %s" Config.author.name title in
    let path = Fpath.(md_dir / file |> add_ext "md") in
    Template.landing_page_of_file title' path
  in
  route, page'

let page ~title file =
  let route = "/" ^ file in
  let page' () =
    let title' = Printf.sprintf "%s's %s" Config.author.name title in
    let path = Fpath.(md_dir / file |> add_ext "md") in
    Template.page_of_file title' path
  in
  route, page'

(* TODO way to cache renders if they haven't changed pages *)
let pages () =
  [ landing_page ~title:"Home Page" "home"
  ; page ~title:"Projects" "projects"
  ; page ~title:"Programs" "programs"
  ; page ~title:"Posts" "posts"
  ; page ~title:"Resume" "resume"
  ]
