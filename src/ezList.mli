(**************************************************************************)
(*                                                                        *)
(*   Typerex Libraries                                                    *)
(*                                                                        *)
(*   Copyright 2011-2017 OCamlPro SAS                                     *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(** Extension of the stdlib List module *)

val last : 'a list -> 'a
(** [last l] returns the last elements of [l]. Raise [Not_found] if
    [l] is empty *)

val take : int -> 'a list -> 'a list
(** [take n l] returns the [n] first elements of [l] *)

val drop : int -> 'a list -> 'a list
(** [drop n l] drops the [n] first elements of [l] *)

val make : int -> 'a -> 'a list
(** [make n x] returns a list of [n] times the element [x] *)

val tail_map : ('a -> 'b) -> 'a list -> 'b list
(** Same as {!List.map} but tail recursive *)

val remove : 'a -> 'a list -> 'a list
(** [remove x l] removes all the elements structuraly equal to [x] in
    list [l] *)

val removeq : 'a -> 'a list -> 'a list
(** [removeq x l] removes all the elements physically equal to [x] in
    list [l] *)
