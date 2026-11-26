-- EXPECT: Trailing comma in SELECT clause
module Test.CompileFail.TrailingCommaInSelect where

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

-- This will cause a compile error because the SELECT clause is being used with a trailing comma.
-- \/
-- bad = from usersTable # select @"name, email,"

-- This line is valid and should not cause a compile error.
good = from usersTable # select @"name, email"