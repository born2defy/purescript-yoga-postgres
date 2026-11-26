-- EXPECT: Lacks
module Test.CompileFail.SetAfterSelect where

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

-- This will cause a compile error because the SET clause is being used after a SELECT statement.
-- \/
-- bad = from usersTable # selectAll # set { name: "B" }

-- This line is valid and should not cause a compile error.
good = from usersTable # selectAll
goodtoo = update usersTable # set { name: "B" }