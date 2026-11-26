-- EXPECT: TypesDoNotUnify
module Test.CompileFail.JoinInvalidColumn where

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

-- This will cause a compile error because the SELECT clause is trying to select a column that does not exist in the "users" table schema.
-- \/
-- bad = from usersTable
--   # innerJoin @"users.id = posts.user_id" postsTable
--   # select @"users.nonexistent"

-- This line is valid and should not cause a compile error because it specifies a valid column to select from the "users" table.
good = from usersTable
  # innerJoin @"users.id = posts.user_id" postsTable
  # select @"users.id"  

goodtoo = from usersTable
  # innerJoin @"users.id = posts.user_id" postsTable
  # select @"users.name"

alsogood = from usersTable
  # innerJoin @"users.id = posts.user_id" postsTable
  # select @"posts.title"