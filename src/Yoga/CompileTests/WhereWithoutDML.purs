-- EXPECT: WHERE requires a preceding SELECT, UPDATE (set), or DELETE
module Test.CompileFail.WhereWithoutDML where

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

-- This will cause a compile error because the WHERE clause is being used without a preceding SELECT, UPDATE (set), or DELETE statement.
-- \/
-- bad = from usersTable # where_ @"id = $id"

-- This line is valid and should not cause a compile error.
good = from usersTable # selectAll # where_ @"id = $id"
goodtoo = update usersTable # set { name: "B" } # where_ @"id = $id"
alsogood = update usersTable # delete # where_ @"name = 'shitface1'"