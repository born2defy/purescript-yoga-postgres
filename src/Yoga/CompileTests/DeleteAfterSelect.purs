-- EXPECT: Lacks
module Yoga.CompileTests.DeleteAfterSelect where

import Prelude ((#))
import Data.Maybe (Maybe)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, Unique, from, selectAll, delete) 

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  , email :: String # Unique
  , age :: Maybe Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because DELETE cannot be used after SELECT.
-- \/
-- bad = from usersTable # selectAll # delete

-- These lines are valid and should not cause compile errors.
good = from usersTable # delete
goodtoo = from usersTable # selectAll 