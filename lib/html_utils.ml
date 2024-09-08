open Tyxml

let html_doc_to_string html =
  Format.asprintf "%a" (Html.pp ~indent:true ()) html

let html_elt_to_string elt =
  Format.asprintf "%a" (Html.pp_elt ~indent:true ()) elt

(* TODO replace with safe option once https://github.com/ocaml/omd/issues/82 is closed *)
type 'a unsafe_html = Unsafe_html of 'a Html.elt

let attrs_of_assoc assoc =
  let f (attr, value) = Tyxml_html.Unsafe.string_attrib attr (Option.value value ~default:"") in
  ListLabels.map ~f assoc

let html_of_md : Omd.t -> 'a unsafe_html = fun md ->
  let rec override : Omd_representation.element -> string option = function
    | Omd.Raw str | Omd.Raw_block str ->
      omd_raw_to_html str
    | Omd.Html (elt, attrs, md) | Omd.Html_block (elt, attrs, md) ->
      omd_html_rep_to_html elt attrs md
    | _ -> None
  and omd_raw_to_html str =
    Omd.of_string str |> Omd.to_html |> Option.some
  and omd_html_rep_to_html elt attrs md =
    let md' = Omd.to_html ~override md in
    let attrs = attrs_of_assoc attrs in
    let content = Tyxml_html.Unsafe.data md' in
    Tyxml_html.Unsafe.node elt ~a:attrs [content]
    |> html_elt_to_string
    |> Option.some
  in
  Unsafe_html (Omd.to_html ~override md |> Tyxml_html.Unsafe.data)

let of_md_file : Fpath.t -> _ unsafe_html = fun path ->
  Fpath.to_string path
  |> In_channel.read_all
  |> Omd.of_string
  |> html_of_md
