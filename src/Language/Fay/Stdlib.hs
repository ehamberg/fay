{-# LANGUAGE NoImplicitPrelude #-}
module Language.Fay.Stdlib
  (($)
  ,(++)
  ,(.)
  ,(=<<)
  ,(**)
  ,Defined(..)
  ,Either(..)
  ,Ordering(..)
  ,show
  ,fromInteger
  ,fromRational
  ,abs
  ,acos
  ,acosh
  ,any
  ,atan
  ,atanh
  ,asin
  ,asinh
  ,compare
  ,concat
  ,concatMap
  ,const
  ,cos
  ,cosh
  ,curry
  ,div
  ,divMod
  ,either
  ,elem
  ,enumFrom
  ,enumFromThen
  ,enumFromTo
  ,enumFromThenTo
  ,error
  ,exp
  ,fromIntegral
  ,filter
  ,find
  ,flip
  ,foldl
  ,foldr
  ,forM_
  ,fst
  ,length
  ,log
  ,logBase
  ,mod
  ,negate
  ,insertBy
  ,intercalate
  ,intersperse
  ,lookup
  ,map
  ,mapM_
  ,maybe
  ,not
  ,nub
  ,null
  ,otherwise
  ,pi
  ,pred
  ,prependToAll
  ,quot
  ,quotRem
  ,recip
  ,rem
  ,reverse
  ,sequence
  ,signum
  ,sin
  ,sinh
  ,snd
  ,sort
  ,sortBy
  ,sqrt
  ,succ
  ,tan
  ,tanh
  ,uncurry
  ,when
  ,zip
  ,zipWith
  ,max
  ,min)
  where

import           Language.Fay.FFI
import           Prelude          (Bool (..), Double, Eq (..), Fractional, Int,
                                   Integer, Maybe (..), Monad (..), Num ((+), (-)),
                                   Fractional ((/)), Ord ((>), (<)), Rational, Show,
                                   String, (&&), (||))

error :: String -> a
error str = case error' str of 0 -> error str ; _ -> error str

error' :: String -> Int
error' = ffi "(function() { throw %1 })()"

show :: (Foreign a,Show a) => a -> String
show = ffi "JSON.stringify(%1)"

data Defined a = Undefined | Defined a
instance Foreign a => Foreign (Defined a)

data Either a b = Left a | Right b

either :: (a -> c) -> (b -> c) -> Either a b -> c
either f _ (Left a) = f a
either _ g (Right b) = g b

-- There is only Double in JS.
fromInteger :: a -> a
fromInteger x = x

fromRational :: a -> a
fromRational x = x

negate :: Num a => a -> a
negate x = (-x)

abs :: (Num a, Ord a) => a -> a
abs x = if x < 0 then negate x else x

signum :: (Num a, Ord a) => a -> a
signum x = if x > 0 then 1 else if x == 0 then 0 else -1

pi :: Double
pi = ffi "Math.PI"

exp :: Double -> Double
exp = ffi "Math.exp(%1)"

sqrt :: Double -> Double
sqrt = ffi "Math.sqrt(%1)"

log :: Double -> Double
log = ffi "Math.log(%1)"

(**) :: Double -> Double -> Double
(**) = ffi "Math.pow(%1,%2)"

logBase :: Double -> Double -> Double
logBase b x = log x / log b

sin :: Double -> Double
sin = ffi "Math.sin(%1)"

tan :: Double -> Double
tan = ffi "Math.tan(%1)"

cos :: Double -> Double
cos = ffi "Math.cos(%1)"

asin :: Double -> Double
asin = ffi "Math.asin(%1)"

atan :: Double -> Double
atan = ffi "Math.atan(%1)"

acos :: Double -> Double
acos = ffi "Math.acos(%1)"

sinh :: Double -> Double
sinh x = (exp x - exp (-x)) / 2

tanh :: Double -> Double
tanh x = let a = exp x ; b = exp (-x) in (a - b) / (a + b)

cosh :: Double -> Double
cosh x = (exp x + exp (-x)) / 2

asinh :: Double -> Double
asinh x = log (x + sqrt(x**2 + 1))

atanh :: Double -> Double
atanh x = log ((1 + x) / (1 - x)) / 2

acosh :: Double -> Double
acosh x = log (x + sqrt (x**2 - 1))

curry :: ((a, b) -> c) -> a -> b -> c
curry f x y = f (x, y)

uncurry :: (a -> b -> c) -> (a, b) -> c
uncurry f p = case p of (x, y) -> f x y

snd :: (t, t1) -> t1
snd (_,x) = x

fst :: (t, t1) -> t
fst (x,_) = x

find :: (a -> Bool) -> [a] -> Maybe a
find p (x:xs) = if p x then Just x else find p xs
find _ [] = Nothing

any :: (t -> Bool) -> [t] -> Bool
any p (x:xs) = if p x then True else any p xs
any _ [] = False

filter :: (a -> Bool) -> [a] -> [a]
filter p (x:xs) = if p x then x : filter p xs else filter p xs
filter _ []     = []

not :: Bool -> Bool
not p = if p then False else True

null :: [t] -> Bool
null [] = True
null _ = False

map :: (a -> b) -> [a] -> [b]
map _ []     = []
map f (x:xs) = f x : map f xs

nub :: Eq a => [a] -> [a]
nub ls = nub' ls []

nub' :: Eq a => [a] -> [a] -> [a]
nub' []     _ = []
nub' (x:xs) ls =
  if elem x ls
     then nub' xs ls
     else x : nub' xs (x : ls)

elem :: Eq a => a -> [a] -> Bool
elem x (y:ys)   = x == y || elem x ys
elem _ []       = False

data Ordering = GT | LT | EQ

sort :: Ord a => [a] -> [a]
sort = sortBy compare

compare :: Ord a => a -> a -> Ordering
compare x y =
  if x > y
     then GT
     else if x < y
             then LT
             else EQ


sortBy :: (t -> t -> Ordering) -> [t] -> [t]
sortBy cmp = foldr (insertBy cmp) []

insertBy :: (a -> a -> Ordering) -> a -> [a] -> [a]
insertBy _   x [] = [x]
insertBy cmp x ys =
  case ys of
    [] -> [x]
    y:ys' ->
      case cmp x y of
         GT -> y : insertBy cmp x ys'
         _  -> x : ys

when :: Monad m => Bool -> m a -> m ()
when p m = if p then m >> return () else return ()

succ :: Num a => a -> a
succ x = x + 1

pred :: Num a => a -> a
pred x = x - 1

enumFrom :: Num a => a -> [a]
enumFrom i = i : enumFrom (i + 1)

enumFromTo :: (Ord t, Num t) => t -> t -> [t]
enumFromTo i n =
  if i > n then [] else i : enumFromTo (i + 1) n

enumFromBy :: (Num t) => t -> t -> [t]
enumFromBy fr by = fr : enumFromBy (fr + by) by

enumFromThen :: (Num t) => t -> t -> [t]
enumFromThen fr th = enumFromBy fr (th - fr)

enumFromByTo :: (Ord t, Num t) => t -> t -> t -> [t]
enumFromByTo fr by to = if by < 0 then neg fr else pos fr
  where neg x = if x < to then [] else x : neg (x + by)
        pos x = if x > to then [] else x : pos (x + by)

enumFromThenTo :: (Ord t, Num t) => t -> t -> t -> [t]
enumFromThenTo fr th to = enumFromByTo fr (th - fr) to

zipWith :: (a->b->c) -> [a]->[b]->[c]
zipWith f (a:as) (b:bs) = f a b : zipWith f as bs
zipWith _ _      _      = []

zip :: [a] -> [b] -> [(a,b)]
zip (a:as) (b:bs) = (a,b) : zip as bs
zip _      _      = []

flip :: (t1 -> t2 -> t) -> t2 -> t1 -> t
flip f x y = f y x

maybe :: t -> (t1 -> t) -> Maybe t1 -> t
maybe m _ Nothing = m
maybe _ f (Just x) = f x

(.) :: (t1 -> t) -> (t2 -> t1) -> t2 -> t
(f . g) x = f (g x)

(++) :: [a] -> [a] -> [a]
x ++ y = conc x y
infixr 5 ++

($) :: (t1 -> t) -> t1 -> t
f $ x = f x
infixr 0 $

-- | Append two lists.
conc :: [a] -> [a] -> [a]
conc (x:xs) ys = x : conc xs ys
conc []     ys = ys

concat :: [[a]] -> [a]
concat = foldr conc []

concatMap :: (a -> [b]) -> [a] -> [b]
concatMap f = foldr ((++) . f) []

foldr :: (t -> t1 -> t1) -> t1 -> [t] -> t1
foldr _ z []     = z
foldr f z (x:xs) = f x (foldr f z xs)

foldl :: (t1 -> t -> t1) -> t1 -> [t] -> t1
foldl _ z []     = z
foldl f z (x:xs) = foldl f (f z x) xs

lookup :: Eq a1 => a1 -> [(a1, a)] -> Maybe a
lookup _key []          =  Nothing
lookup  key ((x,y):xys) =
  if key == x
     then Just y
     else lookup key xys

intersperse :: a -> [a] -> [a]
intersperse _   []      = []
intersperse sep (x:xs)  = x : prependToAll sep xs

prependToAll :: a -> [a] -> [a]
prependToAll _   []     = []
prependToAll sep (x:xs) = sep : x : prependToAll sep xs

intercalate :: [a] -> [[a]] -> [a]
intercalate xs xss = concat (intersperse xs xss)

forM_ :: Monad m => [t] -> (t -> m a) -> m ()
forM_ (x:xs) m = m x >> forM_ xs m
forM_ []     _ = return ()

mapM_ :: Monad m => (a -> m b) -> [a] -> m ()
mapM_ m (x:xs) = m x >> mapM_ m xs
mapM_ _ []     = return ()

const :: a -> b -> a
const a _ = a

length :: [a] -> Int
length xs = length' 0 xs

length' :: Int -> [a] -> Int
length' acc (_:xs) = length' (acc+1) xs
length' acc _ = acc

rem :: Int -> Int -> Int
rem x y = if y == 0 then error "Division by zero" else rem' x y

rem' :: Int -> Int -> Int
rem' = ffi "%1 %% %2"

quot :: Int -> Int -> Int
quot x y = if y == 0 then error "Division by zero" else quot' x y

quot' :: Int -> Int -> Int
quot' = ffi "~~(%1/%2)"

quotRem :: Int -> Int -> (Int, Int)
quotRem x y = (quot x y, rem x y)

div :: Int -> Int -> Int
div x y
  | x > 0 && y < 0 = quot (x-1) y - 1
  | x < 0 && y > 0 = quot (x+1) y - 1
div x y            = quot x y

mod :: Int -> Int -> Int
mod x y
  | x > 0 && y < 0 = rem (x-1) y + y + 1
  | x < 0 && y > 0 = rem (x+1) y + y - 1
mod x y            = rem x y

divMod :: Int -> Int -> (Int, Int)
divMod x y
  | x > 0 && y < 0 = case (x-1) `quotRem` y of (q,r) -> (q-1, r+y+1)
  | x < 0 && y > 1 = case (x+1) `quotRem` y of (q,r) -> (q-1, r+y-1)
divMod x y         = quotRem x y

min :: (Num a, Foreign a) => a -> a -> a
min = ffi "Math.min(%1,%2)"

max :: (Num a, Foreign a) => a -> a -> a
max = ffi "Math.max(%1,%2)"

recip :: Double -> Double
recip x = 1 / x

fromIntegral :: Int -> Double
fromIntegral = ffi "%1"

otherwise :: Bool
otherwise = True

reverse :: [a] -> [a]
reverse (x:xs) = reverse xs ++ [x]
reverse [] = []

(=<<) :: Monad m => (a -> m b) -> m a -> m b
f =<< x = x >>= f
infixl 1 =<<

-- | Evaluate each action in the sequence from left to right,
-- and collect the results.
-- sequence :: [Fay a] -> Fay [a]
sequence :: (Monad m) => [m a] -> m [a]
sequence ms = foldr k (return []) ms
            where
              k m m' = do { x <- m; xs <- m'; return (x:xs) }
