open Shonfeder_net

let assets = Staticmod.run ~dir:"./site/assets" ()

(* TODO: Provide content on thes 404 *)
let not_found = Staticmod.run ~code:"40." ~dest:"./site/assets/error.html" ()


let set_logger () =
  let reporter = Logs_fmt.reporter () in
  Logs.set_reporter reporter;
  Logs.set_level (Some Logs.Info);
  Logs.info (fun m -> m "Running")

let main port verbose =
  (* AHH! Doesn't work :( *)
  Eliom_service.register_eliom_module "shonfeder_net" Content.init;
  set_logger ();
  (* TODO 404 *)
  Ocsigen_server.start
    ?veryverbose:verbose
    ~ports:([`All, port])
    ~debugmode:true
    ~command_pipe:"/tmp/ocsigenserver_command"
    [ Ocsigen_server.host ~port
        [ assets
        ; Eliom.run ()
        ; not_found
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
