-- EXPECT: Lacks
module Test.CompileFail.WhereAfterLimit where

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

-- This will cause a compile error because the WHERE clause is being used after a LIMIT clause.
-- \/
-- bad = from usersTable # selectAll # limit @"10" # where_ @"id = $id"

-- This line is valid and should not cause a compile error.
good = from usersTable # selectAll # limit @"10"
goodtoo = from usersTable # selectAll # where_ @"id = $id" #limit @"10"