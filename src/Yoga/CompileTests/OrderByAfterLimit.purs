-- EXPECT: Lacks
module Test.CompileFail.OrderByAfterLimit where

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

-- This will cause a compile error because ORDER BY is being used after LIMIT.
-- \/
-- bad = from usersTable # selectAll # limit @"10" # orderBy @"name"

-- This line is valid and should not cause a compile error.
good = from usersTable # selectAll # orderBy @"name" # limit @"10"
goodtoo = from usersTable # selectAll # where_ @"age > $age" # orderBy @"name" # limit @"10" 