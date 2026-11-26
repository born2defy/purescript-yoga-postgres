-- EXPECT: ORDER BY requires a column name before ASC/DESC
module Test.CompileFail.OrderByOnlyModifier where

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

-- This will cause a compile error because ORDER BY is being used with only a modifier (ASC/DESC) and no column name.
-- \/ 
-- bad = from usersTable # selectAll # orderBy @"ASC"

-- This line is valid and should not cause a compile error.
good = from usersTable # selectAll # orderBy @"name ASC"
goodtoo = from usersTable # selectAll # where_ @"age > $age" # orderBy @"name DESC" # limit @"10"