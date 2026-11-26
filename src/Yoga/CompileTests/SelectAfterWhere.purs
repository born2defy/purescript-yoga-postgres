-- EXPECT: Lacks
module Test.CompileFail.SelectAfterWhere where

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

-- This will cause a compile error because the SELECT clause is being used after a WHERE clause.
-- \/
-- bad = from usersTable # selectAll # where_ @"id = $id" # select @"name"

-- This line is valid and should not cause a compile error.
good = from usersTable # selectAll # where_ @"id = $id"
goodtoo = from usersTable # select @"name" # where_ @"id = $id"