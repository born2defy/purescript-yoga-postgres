-- EXPECT: RETURNING requires a preceding INSERT, UPDATE (set), or DELETE
module Test.CompileFail.ReturningWithoutMutation where

import Data.UUID
import Prelude
import Yoga.Postgres.Schema
import Data.Maybe (Maybe(..))
import Data.Newtype (wrap)
import Effect.Unsafe (unsafePerformEffect)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))

type UsersTable = Table "users"
  ( id :: Int # PrimaryKey # AutoIncrement
  , uuid :: PGUUID # Unique # Default "gen_random_uuid()"
  , name :: String
  , email :: String # Unique
  )

newID :: PGUUID
newID = unsafePerformEffect $ wrap <$> genUUID

usersTable :: Proxy UsersTable
usersTable = Proxy

-- This will cause a compile error because RETURNING is being used without a preceding INSERT, UPDATE (set), or DELETE statement.
-- \/
--bad = from usersTable # returning @"id"

-- This line is valid and should not cause a compile error.
good = from usersTable # insert { name: "A", email: "a@example.com" } # returning @"uuid"

  