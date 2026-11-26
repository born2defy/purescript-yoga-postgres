-- EXPECT: Cons
module Test.CompileFail.OffsetBeforeSelect where

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

-- | This will cause a compile error because the OFFSET clause is being used before a SELECT statement.
-- \/
-- bad = from usersTable # offset @"5"

-- | This line is valid and should not cause a compile error.
good = from usersTable # selectAll # offset @"5"
goodtoo = from usersTable # selectAll # where_ @"age > $n" # offset @"$m"
alsoGood = from usersTable # selectAll # where_ @"age = $n" # offset @"10"
