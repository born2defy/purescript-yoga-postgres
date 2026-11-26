-- EXPECT: Cons
module Test.CompileFail.OrderByBeforeSelect where

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

-- This will cause a compile error because ORDER BY is being used before SELECT.
-- \/ 
-- bad = from usersTable # orderBy @"name"

-- This line is valid and should not cause a compile error.
good = from usersTable # selectAll # orderBy @"name"
goodtoo = from usersTable # selectAll # where_ @"age > $age" # orderBy @"name" # limit @"10"