-- EXPECT: Cons
module Test.CompileFail.OnConflictOnUpdate where

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

-- This will cause a compile error because an update overrides conflicts.
-- \/
-- bad = from usersTable # set { name: "B" } # onConflictDoNothing @"email"

-- This line is valid and should not cause a compile error.
good = from usersTable # insert { name: "A", email: "a@b.com" } # onConflict @"email" @"DO UPDATE SET age = EXCLUDED.age"
goodtoo = update usersTable # set { name: "B" } # where_ @"email = $email"
alsogood = update usersTable # set { age: Just 10 } # where_ @"id = $id"
