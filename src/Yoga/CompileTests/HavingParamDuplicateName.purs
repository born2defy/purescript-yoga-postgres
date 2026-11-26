-- EXPECT: Nub
module Test.CompileFail.HavingParamDuplicateName where

import Prelude
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, groupBy, having, select, where_)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the HAVING clause is using a parameter name that is already used in the WHERE clause.
-- \/
-- bad = from usersTable
--   # select @"name, COUNT(*) AS cnt"
--   # where_ @"name = $x"
--   # groupBy @"name"
--   # having @"COUNT(*) > $x"

--  This line is valid and should not cause a compile error.
good = from usersTable
  # select @"name, COUNT(*) AS cnt"
  # where_ @"name = $x"
  # groupBy @"name"   
  # having @"COUNT(*) > $y"