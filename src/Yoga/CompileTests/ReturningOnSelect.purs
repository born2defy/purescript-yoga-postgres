-- EXPECT: Lacks
module Test.CompileFail.ReturningOnSelect where

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

-- This will cause a compile error because RETURNING is being used on a SELECT statement. 
-- \/
-- bad = from usersTable # selectAll # returning @"id"

--- This line is valid and should not cause a compile error.
good = update usersTable # set { name: "B" } # where_ @"age > $age" # returning @"name, age, id" 
goodtoo = update usersTable # set { name: "B" } # where_ @"age > $age" # returningAll
alsogood = update usersTable # set { name: "B" } # where_ @"age > 10" # returningAll
alsogoodtoo = update usersTable # set { name: "B" } # where_ @"name = 'ten'" # returningAll