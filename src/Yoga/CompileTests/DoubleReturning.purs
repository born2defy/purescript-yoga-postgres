-- EXPECT: Lacks
module Test.CompileFail.DoubleReturning where

import Prelude
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, insert, returning)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because two RETURNING clauses are being chained together, which is not allowed in a single query.
-- \/
-- bad = from usersTable # insert { name: "A", email: "a@b.com" } # returning @"id" # returning @"name"

-- These lines are valid and should not cause compile errors.
good = from usersTable # insert { name: "A", email: "a@b.com" } # returning @"id"
goodtoo = from usersTable # insert { name: "A", email: "a@b.com" } # returning @"name"
alsogood = from usersTable # insert { name: "A", email: "a@b.com" } # returning @"email"