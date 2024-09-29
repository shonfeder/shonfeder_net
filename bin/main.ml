open Shonfeder_net

let assets = Staticmod.run ~cache:604800 ~dir:"./site/assets" ()

(* TODO: Provide content on thes 404 *)
let not_found = Staticmod.run ~code:"40." ~dest:"./site/assets/error.html" ()

module Config : Config.S = struct
  open Config
  let author =
    { name = "Shon Feder"
    ; email = "shon.feder@gmail.com"
    }
end

module _ = Template.Make (Config)

let set_logger () =
  let reporter = Logs_fmt.reporter () in
  Logs.set_reporter reporter;
  Logs.set_level (Some Logs.Info);
  Logs.info (fun m -> m "Running")

let main port verbose =
  set_logger ();
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

let usage_msg = "shonfeder_net [-verbose] [-port=3000]"
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
