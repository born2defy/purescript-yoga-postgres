-- EXPECT: Cons
module Test.CompileFail.HavingBeforeGroupBy where

import Prelude
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, groupBy, having, select)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the HAVING clause is being used without a preceding GROUP BY clause.
-- \/
-- bad = from usersTable # select @"name" # having @"COUNT(*) > 5"

-- This line is valid and should not cause a compile error.
good = from usersTable # select @"name" # groupBy @"name" # having @"COUNT(*) > 5"
