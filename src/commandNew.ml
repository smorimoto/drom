(**************************************************************************)
(*                                                                        *)
(*    Copyright 2020 OCamlPro & Origin Labs                               *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

open Types
open Ezcmd.TYPES

let cmd_name = "new"

(* lookup for "drom.toml" and update it *)
let action ~project_name ?kind ?mode ~inplace =
  let config = Lazy.force Config.config in
  let project, create = match !project_name with
    | None ->
      Project.project_of_toml "drom.toml", false
    | Some name ->
      let license = match config.config_license with
        | None -> License.LGPL2.key
        | Some license -> license
      in
      let p =
        {
          name ;
          version = "0.1.0" ;
          edition = Globals.current_ocaml_edition ;
          min_edition = Globals.current_ocaml_edition ;
          kind = Program ;
          mode = Binary ;
          authors = [ Project.find_author config ] ;
          synopsis = Globals.default_synopsis ~name ;
          description = Globals.default_description ~name ;
          dependencies = [];
          tools = [ "dune", Globals.current_dune_version ];
          github_organization = config.config_github_organization ;
          homepage = None ;
          doc_api = None ;
          doc_gen = None ;
          bug_reports = None ;
          license ;
          dev_repo = None ;
          copyright = config.config_copyright ;
          wrapped = true ;
          ignore = [];
        } in
      let create =
        if !inplace then true else
          let create = not ( Sys.file_exists name ) in
          if create then
            EzFile.make_dir ~p:true name ;
          Unix.chdir name ;
          create
      in
      p, create
  in
  Update.update_files ~create ?kind ?mode ~git:true project

let cmd =
  let project_name = ref None in
  let kind = ref None in
  let mode = ref None in
  let inplace = ref false in
  {
    cmd_name ;
    cmd_action = (fun () ->
        action ~project_name
          ?mode:!mode
          ?kind:!kind ~inplace);
    cmd_args = [

      [ "both" ], Arg.Unit (fun () -> kind := Some Both ),
      Ezcmd.info "Project contains both a library and a program" ;
      [ "library" ], Arg.Unit (fun () -> kind := Some Library ),
      Ezcmd.info "Project contains only a library" ;
      [ "program" ], Arg.Unit (fun () -> kind := Some Program ),
      Ezcmd.info "Project contains only a program" ;

      [ "binary" ], Arg.Unit (fun () -> mode := Some Binary ),
      Ezcmd.info "Compile to binary" ;
      [ "javascript" ], Arg.Unit (fun () -> mode := Some Javascript ),
      Ezcmd.info "Compile to javascript" ;

      [ "inplace" ], Arg.Set inplace,
      Ezcmd.info "Create project in the the current directory" ;

      [], Arg.Anon (0, fun name -> project_name := Some name),
      Ezcmd.info "Name of the project" ;
    ];
    cmd_man = [];
    cmd_doc = "Create an initial project";
  }