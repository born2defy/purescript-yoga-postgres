-- EXPECT: not found in any table
module Test.CompileFail.OverClauseNonexistentColumn where

import Prelude
import Data.Maybe (Maybe)
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

-- This will cause a compile error because the OVER clause is being used with a nonexistent column.
-- \/
-- bad = from usersTable # select @"name, ROW_NUMBER() OVER (ORDER BY nonexistent_column) AS rn"

-- This line is valid and should not cause a compile error.
good = from usersTable # select @"name, ROW_NUMBER() OVER (PARTITION BY age ORDER BY name) AS rn"
goodtoo = from usersTable # select @"name, ROW_NUMBER() OVER (ORDER BY age) AS rn"