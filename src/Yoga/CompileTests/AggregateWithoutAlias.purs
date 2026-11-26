-- EXPECT: Aggregate function requires AS alias
module Yoga.CompileTests.AggregateWithoutAlias where

import Prelude 
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, select) 

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy


-- This will cause a compile error due to the lack of an alias for the COUNT(*) aggregate function.
-- \/
-- bad = from usersTable # select @"COUNT(*)"

-- This line is valid and should not cause a compile error.
good = from usersTable # select @"COUNT(*) as count" 