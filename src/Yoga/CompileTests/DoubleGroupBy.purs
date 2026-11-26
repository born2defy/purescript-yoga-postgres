-- EXPECT: Lacks
module Test.CompileFail.DoubleGroupBy where

import Prelude ((#))
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, select, groupBy)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the same column "name" is being grouped by twice in the SELECT statement.
-- \/
-- bad = from usersTable # select @"name" # groupBy @"name" # groupBy @"name"

-- This line is valid and should not cause a compile error.
good = from usersTable # select @"name" # groupBy @"name"
