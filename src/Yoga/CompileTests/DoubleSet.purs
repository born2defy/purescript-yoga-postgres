-- EXPECT: Lacks
module Test.CompileFail.DoubleSet where

import Prelude

import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, set, update)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because two SET clauses are being chained together, which is not allowed in a single query.
-- \/
-- bad = update usersTable # set { name: "A" } # set { name: "B" }

-- This line is valid and should not cause a compile error.
good = update usersTable # set { name: "A" }
