(**************************************************************************)
(*                                                                        *)
(*    Copyright 2020 OCamlPro & Origin Labs                               *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

let template_DOTgithub_workflows_ci_ml =
  {|!{github:skip}!{workflows:skip}
(* Credits: https://github.com/ocaml/dune *)
open StdLabels

let skip_test =
  match Sys.getenv "SKIP_TEST" with
  | exception Not_found -> false
  | s -> bool_of_string s

let run cmd args =
  (* broken when arguments contain spaces but it's good enough for now. *)
  let cmd = String.concat " " (cmd :: args) in
  match Sys.command cmd with
  | 0 -> ()
  | n ->
    Printf.eprintf "'%s' failed with code %d" cmd n;
    exit n

let opam args = run "opam" args

let pin () =
  let packages =
    let packages = Sys.readdir "." |> Array.to_list in
    let packages =
      List.fold_left packages ~init:[] ~f:(fun acc fname ->
          if Filename.check_suffix fname ".opam" then
            Filename.chop_suffix fname ".opam" :: acc
          else
            acc)
    in
    if skip_test then
      List.filter packages ~f:(fun pkg -> pkg = "dune")
    else
      packages
  in
  List.iter packages ~f:(fun package ->
      opam [ "pin"; "add"; package ^ ".next"; "."; "--no-action" ])

let test () =
    opam [ "install"; "."; "--deps-only"; "--with-test" ];
    run "make" [ "dev-deps" ];
    run "make" [ "test" ]

let () =
  match Sys.argv with
  | [| _; "pin" |] -> pin ()
  | [| _; "test" |] -> test ()
  | _ ->
    prerr_endline "Usage: ci.ml [pin | test]";
    exit 1
|}

let template_DOTgithub_workflows_workflow_yml =
  {|!{github:skip}!{workflows:skip}
name: Main Workflow

on:
  push:
    branches:
      - master
  pull_request:
    branches:
      - master

jobs:
  build:
    strategy:
      fail-fast: false
      matrix:
        os:
          - macos-latest
          - ubuntu-latest
!{comment-if-not-windows-ci}          - windows-latest
        ocaml-version:
          - !{edition}
        skip_test:
          - false
!{include-for-min-edition}

    env:
      SKIP_TEST: ${{ matrix.skip_test }}
      OCAML_VERSION: ${{ matrix.ocaml-version }}
      OS: ${{ matrix.os }}

    runs-on: ${{ matrix.os }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Cache
        uses: actions/cache@v2
        with:
          path: /home/runner/.opam
          key: ${{ runner.os }}-!{name}-opam-cache-${{ hashFiles('*.opam') }}
      - name: Use OCaml ${{ matrix.ocaml-version }}
        uses: avsm/setup-ocaml@v1
        with:
          ocaml-version: ${{ matrix.ocaml-version }}

      - name: Set git user
        run: |
          git config --global user.name github-actions
          git config --global user.email github-actions-bot@users.noreply.github.com

      - run: opam exec -- ocaml .github/workflows/ci.ml pin

      - run: opam install ./*.opam --deps-only --with-test

      - run: opam exec -- make all

      - name: run test suite
        run: opam exec -- ocaml .github/workflows/ci.ml test
        if: env.SKIP_TEST != 'true'

      - name: test source is well formatted
        run: opam exec -- make fmt-check
        continue-on-error: true
        if: env.OCAML_VERSION == '!{edition}' && env.OS == 'ubuntu-latest'
|}

let project_files =
  [
    (".github/workflows/workflow.yml", template_DOTgithub_workflows_workflow_yml);
    (".github/workflows/ci.ml", template_DOTgithub_workflows_ci_ml);
  ]
