-- EXPECT: Cons
module Test.CompileFail.UnionWithoutSelect where

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

-- This will cause a compile error because the UNION operation is being used without a SELECT statement.
-- \/
-- bad = (from usersTable) `union` (from usersTable)

-- This line is valid and should not cause a compile error.
good = (from usersTable # selectAll) `union` (from usersTable # selectAll)