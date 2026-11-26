-- EXPECT: TypesDoNotUnify
module Test.CompileFail.OnConflictBadExcluded where

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

-- ON CONFLICT target column must exist in the table
-- \/
-- bad = from usersTable # insert { name: "A", email: "a@b.com" } # onConflict @"bogus_column" @"DO UPDATE SET name = EXCLUDED.name"

-- This line is valid and should not cause a compile error.
good = from usersTable # insert { name: "A", email: "a@b.com" } # onConflict @"email" @"DO UPDATE SET age = EXCLUDED.age"
goodtoo = from usersTable # insert { name: "A", email: "a@b.com" } # onConflict @"name " @"DO UPDATE SET email = EXCLUDED.email"