
(* ---- ---- ---- define MyList ---- ---- ---- *)
type 'a my_list =
  | MyNil
  | MyCons of 'a * ('a my_list);;

let rec fold_right_my_list f seed = function
  | MyNil         -> seed
  | MyCons(x, xs) -> f x (fold_right_my_list f seed xs)

let rec fold_left_my_list f seed = function
  | MyNil         -> seed
  | MyCons(x, xs) -> fold_left_my_list f (f seed x) xs

let string_of_my_list string_of_a =
  fold_left_my_list (fun str a -> str ^ (string_of_a a) ^ ". ") ""

(* ---- ---- ---- define MyMonad ---- ---- ---- *)
module type Monadaa = sig
  type 'a m
  val map:  ('a -> 'b  ) -> 'a m -> 'b m
  val bind: ('a -> 'b m) -> 'a m -> 'b m
end

module MonadaaUsage = functor (M: Monadaa) -> struct
  let flat xs ys f =
    M.bind (fun x -> M.map (fun y -> f x y) ys) xs

  let ( *** ) xs ys =
    M.bind (fun x -> M.map (fun y -> (x, y)) ys) xs
end

(* ---- ---- ---- appl MyMonad ---- ---- ---- *)

module Monadaa_my_list : Monadaa with type 'a m = 'a my_list = struct
  type 'a m = 'a my_list

  let map f = fold_right_my_list (fun x y -> MyCons(f x, y)) MyNil
  
  let bind f = fold_right_my_list (fun x y ->
    fold_right_my_list (fun a b -> MyCons(a, b)) y (f x)) MyNil
end

(* ---- ---- ---- Entry Point ---- ---- ---- *)

module MyListUsage = MonadaaUsage(Monadaa_my_list)
open MyListUsage

let main =
  (* Helper functions *)
  let itos = string_of_int in
  let ttos (x, y) = "(" ^ (itos x) ^ "." ^ (itos y) ^ ")" in
  let puts_i_list x = print_endline (string_of_my_list itos x) in
  let puts_t_list x = print_endline (string_of_my_list ttos x) in
  (* values *)
  let one = MyCons( 1, MyCons( 2, MyCons( 3, MyNil))) in
  let ten = MyCons(10, MyCons(20, MyCons(30, MyNil))) in
  puts_i_list (flat one ten (+));
  puts_t_list (one *** ten);
  ()


