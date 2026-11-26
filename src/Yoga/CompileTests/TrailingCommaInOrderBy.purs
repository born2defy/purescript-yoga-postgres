-- EXPECT: Trailing comma in ORDER BY clause
module Test.CompileFail.TrailingCommaInOrderBy where

import Prelude
import Data.Maybe (Maybe(..))
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the ORDER BY clause is being used with a trailing comma.
-- \/
-- bad = from usersTable # selectAll # orderBy @"name,"

-- This line is valid and should not cause a compile error.
good = from usersTable # selectAll # orderBy @"name"