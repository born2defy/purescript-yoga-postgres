-- EXPECT: Lacks
module Test.CompileFail.WhereAfterUnion where

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

-- This will cause a compile error because the WHERE clause is being used after a UNION operation.
-- \/
-- bad = (from usersTable # select @"name") `union` (from usersTable # select @"name") # where_ @"name = $name"

-- This line is valid and should not cause a compile error.
good = (from usersTable # select @"name") `union` (from usersTable # select @"name")
goodtoo = (from usersTable # select @"name" # where_ @"name = $name") `union` (from usersTable # select @"name")
alsogood = (from usersTable # select @"name" # where_ @"name = $name") `union` (from usersTable # select @"name" # where_ @"name = 'asshat7'")