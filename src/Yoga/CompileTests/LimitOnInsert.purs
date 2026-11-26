-- EXPECT: Cons
module Test.CompileFail.LimitOnInsert where

import Prelude
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, insert, limit, select)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the LIMIT clause is being used on an INSERT statement.
-- \/
-- bad = from usersTable # insert { name: "A", email: "a@b.com" } # limit @"10"

-- This line is valid and should not cause a compile error.
good = from usersTable # insert { name: "A", email: "a@b.com" }
goodtoo = from usersTable # select @"name" # limit @"10"