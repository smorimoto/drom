(**************************************************************************)
(*                                                                        *)
(*    Copyright 2020 OCamlPro & Origin Labs                               *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

open Ezcmd.TYPES

let cmd_name = "build"

let action ~switch () =
  let ( _p : Types.project ) = Build.build ~switch () in
  Printf.eprintf "Build OK\n%!"

let cmd =
  let switch = ref None in
  {
    cmd_name ;
    cmd_action = (fun () -> action ~switch ());
    cmd_args = [
    ] @ Build.switch_args switch;
    cmd_man = [];
    cmd_doc = "Build a project";
  }
