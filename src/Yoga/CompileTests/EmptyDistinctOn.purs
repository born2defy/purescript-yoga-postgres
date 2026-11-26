-- EXPECT: Empty column list
module Test.CompileFail.EmptyDistinctOn where

import Prelude
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, selectDistinctOn)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the DISTINCT ON clause is being used with an empty column list.
-- \/
-- bad = from usersTable # selectDistinctOn @"" @"name"

-- This line is valid and should not cause a compile error.
good = from usersTable # selectDistinctOn @"name" @"name"
goodtoo = from usersTable # selectDistinctOn @"name" @"email"
