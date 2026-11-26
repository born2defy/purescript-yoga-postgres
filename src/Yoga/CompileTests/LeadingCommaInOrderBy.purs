-- EXPECT: Unexpected comma in ORDER BY clause
module Test.CompileFail.LeadingCommaInOrderBy where

import Prelude
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, orderBy, selectAll)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the ORDER BY clause is being used with a leading comma.
-- \/
-- bad = from usersTable # selectAll # orderBy @",name"

-- This line is valid and should not cause a compile error.
good = from usersTable # selectAll # orderBy @"name"