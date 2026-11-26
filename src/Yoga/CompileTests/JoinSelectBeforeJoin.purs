-- EXPECT: NoInstanceFound
module Test.CompileFail.JoinSelectBeforeJoin where

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

-- This will cause a compile error because the SELECT clause is being called before the JOIN clause.
-- \/
-- bad = from usersTable
--   # selectAll
--   # innerJoin @"users.id = posts.user_id" postsTable

-- This line is valid and should not cause a compile error because it specifies the JOIN clause before the SELECT clause, which is the correct order for this query builder.

good= from usersTable
  # innerJoin @"users.id = posts.user_id" postsTable
  # select @"users.name"    

goodtoo = from usersTable
  # innerJoin @"users.id = posts.user_id" postsTable
  # select @"posts.title" 