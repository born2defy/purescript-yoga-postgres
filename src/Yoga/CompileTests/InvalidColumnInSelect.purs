-- EXPECT: NoInstanceFound
module Test.CompileFail.InvalidColumnInSelect where

import Prelude
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, select)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the SELECT clause is being used with a column that does not exist in the table schema.
-- \/
-- bad = from usersTable # select @"nonexistent"

-- This line is valid and should not cause a compile error.
good = from usersTable # select @"name"
goodtoo = from usersTable # select @"age"
