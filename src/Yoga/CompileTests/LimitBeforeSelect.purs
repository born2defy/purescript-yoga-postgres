-- EXPECT: Cons
module Test.CompileFail.LimitBeforeSelect where

import Prelude
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, limit, select, selectAll)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the LIMIT clause is being used before the SELECT clause.
-- \/
-- bad = from usersTable # limit @"10"

-- This line is valid and should not cause a compile error.   
good = from usersTable # selectAll # limit @"10"
goodtoo = from usersTable # select @"name" # limit @"10"