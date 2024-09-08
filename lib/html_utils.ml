open Tyxml

(* let html_doc_to_string html = *)
(*   Format.asprintf "%a" (Html.pp ~indent:true ()) html *)

let html_elt_to_string elt =
  Format.asprintf "%a" (Html.pp_elt ~indent:true ()) elt

let attrs_of_assoc assoc =
  let f (attr, value) = Tyxml_html.Unsafe.string_attrib attr (Option.value value ~default:"") in
  ListLabels.map ~f assoc

let of_md_file = fun path ->
  In_channel.input_all
  |> In_channel.with_open_text (Fpath.to_string path)
  |> Cmarkit.Doc.of_string
  |> Cmarkit_html.of_doc ~safe:false
  |> fun x -> (Tyxml_html.Unsafe.data x)
