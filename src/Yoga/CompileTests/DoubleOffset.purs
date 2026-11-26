-- EXPECT: Lacks
module Test.CompileFail.DoubleOffset where

import Prelude ((#))
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, offset, selectAll)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because two OFFSET clauses are being chained together, which is not allowed in a single query.
-- \/
-- bad = from usersTable # selectAll # offset @"10" # offset @"5"

-- This line is valid and should not cause a compile error.
good = from usersTable # selectAll # offset @"10"
