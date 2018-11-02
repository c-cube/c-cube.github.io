#!/usr/bin/env ocaml

(*
copyright (c) 2013, simon cruanes
all rights reserved.

redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.  redistributions in binary
form must reproduce the above copyright notice, this list of conditions and the
following disclaimer in the documentation and/or other materials provided with
the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)

(** {1 Dereference symbolic links} *)

(** This program replaces symbolic links by their actual content, on
    unix systems *)

#load "unix.cma";;

type deref =
  | Always
  | Once
  | Never

let verbose = ref false

let abspath file =
  if Filename.is_relative file
    then Filename.concat (Unix.getcwd ()) file
    else file

let deref_file ~deref origin =
  let rec lookup ~deref filename =
    if !verbose then Printf.eprintf "deref file %s\n" filename;
    let stat = Unix.lstat filename in
    match stat.Unix.st_kind, deref with
    | Unix.S_LNK, Once ->
      (* recurse for the last time *)
      let filename' = Unix.readlink filename in
      lookup ~deref:Never filename'
    | Unix.S_LNK, Always ->
      (* recurse *)
      let filename' = Unix.readlink filename in
      lookup ~deref filename'
    | _, _ ->
      (* replace if not equal *)
      let filename = abspath filename in
      let origin = abspath origin in
      if filename <> origin
        then begin
          if !verbose
            then Printf.eprintf "replace %s by %s\n" origin filename;
          Unix.unlink origin;
          let cmd = Printf.sprintf "/bin/cp '%s' '%s'" filename origin in
          let status = Unix.system cmd in
          match status with
          | Unix.WEXITED 0 -> ()
          | _ -> if !verbose then Printf.eprintf "error executing 'cp' for file %s\n" origin
        end
  in 
  lookup ~deref origin

let deref = ref Always

let options =
  [ "-once", Arg.Unit (fun () -> deref := Once), "only dereference once"
  ; "-verbose", Arg.Set verbose, "verbose mode"
  ]

let files = Queue.create ()
let add_file f = Queue.push f files

let _ =
  Arg.parse options add_file "replace given symlinks by their content";
  Queue.iter (deref_file ~deref:!deref) files
  
