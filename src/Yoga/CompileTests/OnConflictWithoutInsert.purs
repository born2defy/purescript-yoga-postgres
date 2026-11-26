-- EXPECT: Cons
module Test.CompileFail.OnConflictWithoutInsert where

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

-- This will cause a compile error because ON CONFLICT is being used without an INSERT statement.
-- \/
-- bad = from usersTable # selectAll # onConflictDoNothing @"email"

-- This line is valid and should not cause a compile error.
good = from usersTable # insert { name: "A", email: "a@b.com" } # onConflictDoNothing @"email"
