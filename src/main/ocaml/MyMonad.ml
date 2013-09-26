
(* ---- ---- ---- define MyList ---- ---- ---- *)
type 'a my_list =
  | MyNil
  | MyCons of 'a * ('a my_list);;

let rec fold_right_my_list f seed = function
  | MyNil         -> seed
  | MyCons(x, xs) -> f x (fold_right_my_list f seed xs)

let rec string_of_int_list = function
  | MyNil -> ""
  | MyCons(a, lst) -> (string_of_int a) ^ ". " ^ string_of_int_list lst

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

module Monadaa_my_list : Monadaa = struct
  type 'a m = 'a my_list

  let map f = fold_right_my_list (fun x y -> MyCons(f x, y)) MyNil
  
  let bind f = fold_right_my_list (fun x y ->
    fold_right_my_list (fun a b -> MyCons(a, b)) y (f x)) MyNil
end

(* ---- ---- ---- Entry Point ---- ---- ---- *)

module MyListUsage = MonadaaUsage(Monadaa_my_list)
open MyListUsage

let ( * ) f g = fun x -> f(g(x));;
let main =
  let one = MyCons( 1, MyCons( 2, MyCons( 3, MyNil))) in
  let ten = MyCons(10, MyCons(20, MyCons(30, MyNil))) in
  (*
  (print_endline * string_of_int_list) (flat one ten ( + ));
  (print_endline * string_of_int_list) (one *** ten);
  *)  
  (print_endline * string_of_int_list) one;
  ()


