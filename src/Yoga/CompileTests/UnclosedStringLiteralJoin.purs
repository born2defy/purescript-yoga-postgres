-- EXPECT: Unclosed string literal
module Test.CompileFail.UnclosedStringLiteralJoin where

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

type PostsTable = Table "posts"
  ( id :: Int # PrimaryKey # AutoIncrement
  , user_id :: Int
  , title :: String
  )

usersTable :: Proxy UsersTable
usersTable = Proxy

postsTable :: Proxy PostsTable
postsTable = Proxy

-- This will cause a compile error because the string literal in the INNER JOIN clause is unclosed.
-- \/
-- bad = from usersTable # innerJoin @"users.id = 'unclosed" postsTable # select @"users.name" 

--  This line is valid and should not cause a compile error.
good = from usersTable # innerJoin @"users.id = posts.id" postsTable # select @"users.name"