-- EXPECT: RETURNING requires a preceding INSERT, UPDATE (set), or DELETE
module Test.CompileFail.ReturningWithoutMutation where

import Prelude
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

bad = from usersTable # returning @"id"
