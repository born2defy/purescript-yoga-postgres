-- EXPECT: Cons
module Test.CompileFail.OrderByOnUpdate where

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

-- This will cause a compile error because ORDER BY is being used on an UPDATE statement.
-- \/
--bad = update usersTable # set { name: "B" } # orderBy @"name"

-- This line is valid and should not cause a compile error.
good = update usersTable # set { name: "B" } # where_ @"email = $email"
goodtoo = from usersTable # selectAll # where_ @"age > $age" # orderBy @"name" # limit @"10"