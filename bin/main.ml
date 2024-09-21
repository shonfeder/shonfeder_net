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

let main port verbose =
  add_services ();
  set_logger ();
  Ocsigen_server.start
    ?veryverbose:verbose
    ~ports:([`All, port])
    ~debugmode:true
    ~command_pipe:"/tmp/ocsigenserver_command"
    [ Ocsigen_server.host ~port
        [ assets
        ; Eliom.run ()
        ]
    ]

let usage_msg = "shonfeder_net [-verbose] [-port ]"
let verbose = ref None
let port = ref 3000

let set_unit r = Arg.Unit (fun () -> r := Some ())

let speclist =
  [ "-verbose", set_unit verbose, "Output debug information"
  ; "-port"   , Arg.Set_int port, "Output debug information"
  ]

let () =
  Arg.parse speclist ignore usage_msg;
  main !port !verbose
