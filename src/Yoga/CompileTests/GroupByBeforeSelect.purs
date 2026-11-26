-- EXPECT: Cons
module Test.CompileFail.GroupByBeforeSelect where

import Prelude
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, groupBy, select)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the GROUP BY clause is being used without a preceding SELECT clause.
-- \/
-- bad = from usersTable # groupBy @"name"

--  This line is valid and should not cause a compile error.
good = from usersTable # select @"name" # groupBy @"name"
