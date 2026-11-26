-- EXPECT: LIMIT/OFFSET must be a non-negative integer or $parameter
module Test.CompileFail.InvalidLimitNegative where

import Prelude
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, limit, selectAll)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the LIMIT clause is being used with a negative value. LIMIT must be a non-negative integer or a parameter.
-- \/
-- bad = from usersTable # selectAll # limit @"-5"

-- This line is valid and should not cause a compile error.
good = from usersTable # selectAll # limit @"5"
