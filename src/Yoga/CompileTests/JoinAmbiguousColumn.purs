-- EXPECT: NoInstanceFound
module Test.CompileFail.JoinAmbiguousColumn where

import Prelude
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres.Schema (AutoIncrement, PrimaryKey, Table, from, innerJoin, select)

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , name :: String
  )

type PostsTable = Table "posts"
  ( id :: Int # PrimaryKey # AutoIncrement
  , title :: String
  , user_id :: Int
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

postsTable :: Proxy PostsTable
postsTable = Proxy

-- This will cause a compile error because the SELECT clause is ambiguous. Both the "users" and "posts" tables have an "id" column, and the query does not specify which one to select.
-- \/
-- bad = from usersTable
--  # innerJoin @"users.id = posts.user_id" postsTable
--  # select @"id"

-- This line is valid and should not cause a compile error because it specifies which "id" column to select from the "users" table.
good = from usersTable
  # innerJoin @"users.id = posts.user_id" postsTable
  # select @"users.id"