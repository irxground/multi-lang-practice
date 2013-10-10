
---- ---- ---- define MyList ---- ---- ----
data MyList a =
    MyNil
  | MyCons a (MyList a)

myFoldRight :: (a -> b -> b) -> b -> MyList a -> b
myFoldRight _ x MyNil = x
myFoldRight f x (MyCons y ys) = f y (myFoldRight f x ys)

instance Show a => Show (MyList a) where
  show = myFoldRight (\x -> \y -> (show x) ++ ". " ++ y) ""

---- ---- ---- define MyMonad ---- ---- ----
class Functoo m where
  myMap  :: (a ->   b) -> m a -> m b

class Functoo m => Monadaa m where
  myBind :: (a -> m b) -> m a -> m b

flat :: Monadaa m => m a -> m a -> (a -> a -> a) -> m a
flat xs ys f = myBind (\x -> myMap (\y -> f x y) ys) xs

(***) :: Monadaa m => m a -> m b -> m (a, b)
(***) xs ys = myBind (\x -> myMap (\y -> (x, y)) ys) xs

---- ---- ---- appl MyMonad ---- ---- ----
instance Functoo MyList where
  myMap f = myFoldRight (MyCons . f) MyNil

instance Monadaa MyList where
  myBind f = myFoldRight (\x -> \ys -> myFoldRight MyCons ys (f x)) MyNil

---- ---- ---- Entry Point ---- ---- ----
main =
  let
    one = MyCons 1  $ MyCons 2  $ MyCons 3  $ MyNil
    ten = MyCons 10 $ MyCons 20 $ MyCons 30 $ MyNil
  in do
    putStrLn $ show $ flat one ten (+)
    putStrLn $ show $ (one *** ten)

