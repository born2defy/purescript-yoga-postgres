-- EXPECT: Lacks
module Test.CompileFail.WhereAfterGroupBy where

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

-- This will cause a compile error because the WHERE clause is being used after a GROUP BY clause.
-- \/
-- bad = from usersTable # select @"name" # groupBy @"name" # where_ @"age > $age"

-- This line is valid and should not cause a compile error.
good = from usersTable # select @"name" # groupBy @"name"
goodtoo = from usersTable # select @"name" # where_ @"age > $age" # groupBy @"name"
alsogood = from usersTable # select @"name" # where_ @"age > 10"