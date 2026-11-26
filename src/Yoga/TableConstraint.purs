module Yoga.TableConstraint where

import Data.Symbol
import Prelude
import Type.Proxy

import Data.Array (all, uncons)
import Data.Maybe (Maybe(..))
import Data.Time (Millisecond)
import Pipes.Prelude (scan)
import Prim.Row as Row
import Prim.Symbol as Symbol
import Prim.TypeError (class Fail, Text)


class ValidateFields (list :: SList) (rows :: Row Type) | list -> rows

instance ValidateFields SNil row 
instance 
  ( Row.Cons field anytype trash rows
  , ValidateFields tail rows
  ) => ValidateFields (SCons field tail) rows

-- | Polykinded Low Weight Type-Level List
data SList
foreign import data SCons :: Symbol -> SList -> SList
foreign import data SNil :: SList

class PrintSList :: SList -> Constraint
class PrintSList list where
  printSList :: Proxy list -> String

instance PrintSList SNil where
  printSList _ = "SNil"

instance 
  ( IsSymbol x 
  , PrintSList rest
  ) =>PrintSList (SCons x rest) where
  printSList _ = "(SCons " <> reflectSymbol (Proxy @x) <> format (printSList (Proxy @rest))
    where
      format x 
        | x == ""   = ")"
        | otherwise = " " <> x <> ")"      

-- | Parsing
parseTextToList :: forall @string cleanstring wordList
   . IsSymbol string
  => SkipLeadingSpacesAndCommas string cleanstring
  => ParseText cleanstring wordList
  => PrintSList wordList
  => String
parseTextToList = printSList $ Proxy @wordList

parseTextToListValidated :: forall string cleanstring wordList rows
   . IsSymbol string
  => ValidateFields wordList rows
  => SkipLeadingSpacesAndCommas string cleanstring
  => ParseText cleanstring wordList
  => PrintSList wordList
  => Proxy rows
  -> Proxy string
  -> String
parseTextToListValidated _ _ = printSList $ Proxy @wordList

type P1 = "id, time, mellons"
type P2 = "   , id, time, mellons"
type P3 = "  , , id,   time, mellons "
type P4 = "  ,, , id, time, mellons."
type P5 = "    , id, time, mellons,"
type P6 = "    , id2, time, mellons,"
type P7 = "    , id2,   "
type P8 = "    , time, mellons,"
type P9 = "    , , mellons,"

data Titty = Titty 

type ValidRows = 
  ( id :: Int
  , time :: Millisecond
  , mellons :: Array Titty
  )

type InvalidRows = 
  ( id2 :: Int
  , time :: Millisecond
  , mellons :: Array Titty
  )

tryParse :: forall @string wordList cleanstring 
   . IsSymbol string
  => SkipLeadingSpacesAndCommas string cleanstring
  => ParseText cleanstring wordList
  => PrintSList wordList
  => String
tryParse = parseTextToList @string 


tryValidParse :: forall string wordList cleanstring rows
   . IsSymbol string
  => ValidateFields wordList rows
  => SkipLeadingSpacesAndCommas string cleanstring
  => ParseText cleanstring wordList
  => PrintSList wordList
  => Proxy rows
  -> Proxy string
  -> String
tryValidParse p s = parseTextToListValidated p s

class ParseText (string :: Symbol) (wordList :: SList) | string -> wordList
class ParseCharacter (head :: Symbol) (tail :: Symbol) (wordList :: SList) | head tail -> wordList

instance ParseText "" (SCons "" SNil)
else instance 
  ( Symbol.Cons head tail string
  , ParseCharacter head tail wordList
  ) => ParseText string wordList

-- | Skip ending commas, spaces, and periods
instance ParseCharacter "," "" (SCons "" SNil)
else instance ParseCharacter " " "" (SCons "" SNil)
else instance ParseCharacter "." "" (SCons "" SNil)
else instance ParseCharacter char "" (SCons char SNil)
else instance 
  ( Symbol.Cons head tail string
  , ParseText tail rest
  ) =>  ParseCharacter "," string (SCons "" rest)

-- | Skip spaces
else instance ParseText tail rest =>  ParseCharacter " " tail rest

else instance 
  ( ParseText tail (SCons acc rest)
  , Symbol.Cons head acc acc2
  ) => ParseCharacter head tail (SCons acc2 rest)  

-- Skip leading spaces
class SkipLeadingSpacesAndCommas :: Symbol -> Symbol -> Constraint
class SkipLeadingSpacesAndCommas sym result | sym -> result

instance SkipLeadingSpacesAndCommas "" ""
else instance
  ( Symbol.Cons head tail sym
  , SkipLeadingSpacesAndCommasGo head tail result
  ) => SkipLeadingSpacesAndCommas sym result

class SkipLeadingSpacesAndCommasGo :: Symbol -> Symbol -> Symbol -> Constraint
class SkipLeadingSpacesAndCommasGo head tail result | head tail -> result

instance SkipLeadingSpacesAndCommas tail result => SkipLeadingSpacesAndCommasGo " " tail result
else instance SkipLeadingSpacesAndCommas tail result => SkipLeadingSpacesAndCommasGo "," tail result
else instance Symbol.Cons head tail result => SkipLeadingSpacesAndCommasGo head tail result

stripSpaces :: forall @string skipped
    . IsSymbol skipped
   => SkipLeadingSpacesAndCommas string skipped
   => String
stripSpaces = reflectSymbol (Proxy @skipped)

try1 :: String
try1 = stripSpaces @"hell,oworld "

try2 :: String
try2 = stripSpaces @",hell oworld "

try3 :: String
try3 = stripSpaces @"  ,,  hell oworld "

allEqual :: forall a. Eq a => Array a -> Boolean
allEqual arr = case uncons arr of
  Nothing -> true -- Returns true for an empty array (vacuous truth)
  Just { head, tail } -> all (_ == head) tail



  