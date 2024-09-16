open Shonfeder_net

let assets = Staticmod.run ~dir:"./site/assets" ()

let add_services () =
  let add_service (route, page) =
    let service = Eliom_service.create
        ~path:(Eliom_service.Path route)
        ~meth:(Eliom_service.Get (Eliom_parameter.unit))
        ()
    in
    (* TODO Replace with Eliom_registration.Html and services *)
    Eliom_registration.Html_text.register ~service
      (fun () () ->
         ()
         |> page
         |> Format.asprintf "%a" (Tyxml.Html.pp ())
         |> Lwt.return)
  in
  Content.pages ()
  |> List.iter add_service

let set_logger () =
  let reporter = Logs_fmt.reporter () in
  Logs.set_reporter reporter;
  Logs.set_level (Some Logs.Info);
  Logs.info (fun m -> m "Running")

let run () =
  (* TODO Need to parse args to allow setting the port *)
  let port = 3000 in
  add_services ();
  set_logger ();
  Ocsigen_server.start
    ~ports:([`All, port])
    ~debugmode:true ~veryverbose:()
    [ Ocsigen_server.host ~port
        [ assets
        ; Eliom.run ()
        ]
    ]

let () = run ()
