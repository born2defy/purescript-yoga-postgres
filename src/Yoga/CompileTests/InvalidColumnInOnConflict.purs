-- EXPECT: TypesDoNotUnify
module Test.CompileFail.InvalidColumnInOnConflict where

import Prelude
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, insert, onConflictDoNothing)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the ON CONFLICT clause is being used with a column that does not exist in the table schema.
-- \/
-- bad = from usersTable # insert { name: "A", email: "a@b.com" } # onConflictDoNothing @"nonexistent"

-- This line is valid and should not cause a compile error.
good = from usersTable # insert { name: "A", email: "a@b.com" } # onConflictDoNothing @"email"
