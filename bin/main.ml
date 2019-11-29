open! Core_kernel
open Opium.Std

open Shonfeder_net

let assets =
  Middleware.static
    ~local_path:"./site/assets"
    ~uri_prefix:"/"
    ()

(* let root =
 *   get "/" (fun _req -> `Html (Content.landing_page ()) |> respond') *)

let add_pages app =
  let add_page app (route, page) =
    get route (fun _req -> `Html (page ()) |> respond') app
  in
  List.fold ~f:add_page ~init:app (Content.pages ())

(* let programs =
 *   get "/programs" (fun _req -> `Html (Content.programs_page ()) |> respond') *)

let log_reporter () = Lwt.return (Logs_fmt.reporter ())

let set_logger app =
  let open Lwt.Infix in
  log_reporter () >>=
  fun reporter ->
  Logs.set_reporter reporter;
  Logs.set_level (Some Logs.Info);
  Logs.info (fun m -> m "Running");
  app

let app =
  App.empty
  |> middleware assets
  |> add_pages
(* |> root
 * |> programs *)

let run () =
  match App.run_command' app with
  | `Ok app -> ignore (Lwt_main.run @@ set_logger app)
  | `Error -> exit 1
  | `Not_running -> exit 0

let () = run ()

(* let _ = App.empty
 *         |> middleware assets
 *         |> root
 *         |> App.run_command *)
