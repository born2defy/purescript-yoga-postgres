-- EXPECT: Aggregate function requires AS alias
module Test.CompileFail.WindowFunctionNoAlias where

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

-- This will cause a compile error because the window function ROW_NUMBER() is being used without an AS alias.
-- \/
-- bad = from usersTable # select @"ROW_NUMBER() OVER (ORDER BY age)"

-- This line is valid and should not cause a compile error.
good = from usersTable # select @"ROW_NUMBER() OVER (ORDER BY age) AS rn"
goodtoo = from usersTable # select @"ROW_NUMBER() OVER (PARTITION BY age ORDER BY name) AS rn"