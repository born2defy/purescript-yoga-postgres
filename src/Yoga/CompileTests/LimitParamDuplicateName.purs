-- EXPECT: Lacks
module Test.CompileFail.LimitParamDuplicateName where

import Prelude
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, limit, selectAll, where_)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the LIMIT clause is being used with a parameter that has a duplicate name.
-- \/
-- bad = from usersTable # selectAll # where_ @"age > $n" # limit @"$n"

-- This line is valid and should not cause a compile error.
good = from usersTable # selectAll # where_ @"age > $n" # limit @"$m"
goodtoo = from usersTable # selectAll # where_ @"age = $n" # limit @"$o"
