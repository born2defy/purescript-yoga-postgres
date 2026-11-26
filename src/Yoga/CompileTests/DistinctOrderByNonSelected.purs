-- EXPECT: ORDER BY column "age" must appear in the SELECT list when using DISTINCT
module Test.CompileFail.DistinctOrderByNonSelected where

import Prelude ((#))
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, selectDistinct, orderBy)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because the ORDER BY column "age" is not included in the SELECT list when using DISTINCT.
--\/
-- bad = from usersTable # selectDistinct @"name" # orderBy @"age"

-- This line is valid and should not cause a compile error.
good = from usersTable # selectDistinct @"name" # orderBy @"name"