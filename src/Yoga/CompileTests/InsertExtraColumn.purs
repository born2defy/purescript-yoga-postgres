-- EXPECT: Union
module Test.CompileFail.InsertExtraColumn where

import Prelude
import Data.Maybe (Maybe(..))
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, insert)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the INSERT operation is being used with an extra column that does not exist in the table schema.
-- \/
-- bad = from usersTable # insert { name: "A", email: "a@b.com", bogus: 42 }

--  This line is valid and should not cause a compile error.
good = from usersTable # insert { name: "A", email: "a@b.com", age: Just 30 }  
