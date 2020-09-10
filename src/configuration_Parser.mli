(* Configuration_Parser -- Parsing configuration files

   Author: Michael Grünewald
   Date: Mon Oct 29 07:36:58 CET 2012

   Copyright © 2012–2015 Michael Grünewald

   This file must be used under the terms of the CeCILL-B.
   This source file is licensed as described in the file COPYING, which
   you should have received as part of this distribution. The terms
   are also available at
   http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.txt *)
(** Parsing configuration files.

    Configuration files in the form of INI files that were common under
    Microsoft systems have grown popular in the open source world, and are
    used my some major pieces of software, like Subversion or GIT.

    We provide a parser to analyse these files.  This parser is a functor
    parameterised by handlers for the events found in a configuration
    file.  These events are of the following kinds:
    - comments;
    - sections;
    - bindings;
    - parse errors. *)

type pos = Lexing.position
(** Position in an input stream. *)

type excerpt
(** The type of excerpts. *)

val startpos : excerpt -> pos
(** The start position of an excerpt. *)

val endpos : excerpt -> pos
(** The end position of an excerpt. *)

val text : excerpt -> string
(** The text of an excerpt. *)

(** Parsing errors. *)
type error =
  | Illegal_character
  | Illegal_escape_sequence
  | Unterminated_string
  | Expecting_binding
  | Expecting_value
  | Expecting_path_elt
  | Expecting_path_sep_or_term

val error_to_string : error -> string
(** Textual description of errors. *)

(** The input signature of the functor [Configuration_Parser.Make]. *)
module type Definition = sig
  type t
  (** The type of functional parser state. *)

  val comment : excerpt -> t -> t
  (** Receive a comment. *)

  val section : excerpt list -> t -> t
  (** Receive a section specification. *)

  val binding : excerpt -> excerpt -> t -> t
  (** Receive a binding specificaton. *)

  val parse_error : pos -> error -> t -> t
  (** Receive a parser error. *)
end

(** The output signature of the functor [Configuration_Parser.Make]. *)
module type S = sig
  type t
  (** The type of functional parser state. *)

  val parse : Lexing.lexbuf -> t -> t
  (** Parse the given lexing buffer stream. *)

  val parse_string : string -> t -> t
  (** Parse the given string. *)

  val parse_channel : in_channel -> t -> t
  (** Parse the given input channel. *)

  val parse_file : string -> t -> t
  (** Parse the given file.

      @raise Sys_error if the file cannot be opened. *)
end

(** Functor building an implementation of the configuration file
    parser given a parser definition. *)
module Make (D : Definition) : S with type t = D.t
