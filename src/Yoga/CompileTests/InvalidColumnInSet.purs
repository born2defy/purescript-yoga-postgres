-- EXPECT: TypesDoNotUnify
module Test.CompileFail.InvalidColumnInSet where

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

-- This will cause a compile error because the SET clause is being used with a column that does not exist in the table schema.
-- \/
-- bad = update usersTable # set { nonexistent: "B" }

-- This line is valid and should not cause a compile error.
good = update usersTable # set { name: "B" }