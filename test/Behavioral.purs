module Test.Postgres.Behavioral where

import Prelude

import Control.Parallel (parTraverse)
import Data.Array as Array
import Data.Date (canonicalDate)
import Data.DateTime (DateTime(..))
import Data.Either (Either(..))
import Data.Enum (toEnum)
import Data.Maybe (Maybe(..), fromJust)
import Data.Identity (Identity)
import Data.Time (Time(..))
import Data.Time.Duration (Milliseconds(..))
import Data.UUID as UUID
import Effect (Effect)
import Effect.Aff (Aff, delay, forkAff, killFiber, throwError, try)
import Effect.Class (liftEffect)
import Effect.Exception (error, message)
import Effect.Ref as Ref
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Foreign (unsafeToForeign)
import JS.BigInt (BigInt)
import JS.BigInt as BigInt
import Partial.Unsafe (unsafePartial)
import Prim.Boolean (True)
import Test.Spec (Spec, SpecT, describe, it)
import Test.Spec.Assertions (shouldEqual, shouldSatisfy)
import Type.Function (type (#))
import Type.Proxy (Proxy(..))
import Yoga.Postgres as PG
import Yoga.Postgres.Schema as Schema
import Yoga.Postgres.TypedQuery as Typed
import Yoga.SQL.PostgresTypes (SQLQuery, arg, combineBuilders, int, sql, str)

isLeft :: forall a b. Either a b -> Boolean
isLeft (Left _) = true
isLeft _ = false

poisonRollback :: PG.Transaction -> Effect Unit
poisonRollback = runEffectFn1 poisonRollbackImpl

foreign import poisonRollbackImpl :: EffectFn1 PG.Transaction Unit

testConnection :: Effect PG.Connection
testConnection = PG.postgres
  { host: PG.PostgresHost "localhost"
  , port: PG.PostgresPort 5434
  , database: PG.PostgresDatabase "test_playground"
  , username: PG.PostgresUsername "postgres"
  , password: PG.PostgresPassword "postgres"
  }

type BehaviorTable = Schema.Table "behavior_values"
  ( id :: Int # Schema.PrimaryKey # Schema.AutoIncrement
  , name :: String
  , optional_int :: Maybe Int
  )

behaviorTable :: Proxy BehaviorTable
behaviorTable = Proxy

type AllDefaultTable = Schema.Table "behavior_defaults"
  ( active :: Boolean # Schema.Default True
  , id :: Int # Schema.PrimaryKey # Schema.AutoIncrement
  )

allDefaultTable :: Proxy AllDefaultTable
allDefaultTable = Proxy

type TxTable = Schema.Table "behavior_tx"
  ( id :: Int # Schema.PrimaryKey # Schema.AutoIncrement
  , name :: String
  )

txTable :: Proxy TxTable
txTable = Proxy

type TemporalParamTable = Schema.Table "behavior_temporal"
  ( document :: Schema.Jsonb
  , event_at :: Schema.TimestampTZ
  , event_date :: Schema.PGDate
  , event_time :: Schema.PGTime
  , label :: String
  , uuid :: Schema.PGUUID
  , optional_event_at :: Maybe Schema.TimestampTZ
  )

temporalParamTable :: Proxy TemporalParamTable
temporalParamTable = Proxy

typedIntQuery :: SQLQuery (n :: Int)
typedIntQuery = sql $ combineBuilders (combineBuilders "SELECT " (int @"n")) "::int AS n"

typedMaybeQuery :: SQLQuery (value :: Maybe Int)
typedMaybeQuery = sql $ combineBuilders (combineBuilders "SELECT " (arg @(Maybe Int) @"value")) "::int AS value"

typedBadDecodeQuery :: SQLQuery ()
typedBadDecodeQuery = sql $ combineBuilders "SELECT 'not-an-int' AS n" ""

typedMutationQuery :: SQLQuery (name :: String)
typedMutationQuery = sql $ combineBuilders (combineBuilders "INSERT INTO behavior_values (name) VALUES (" (str @"name")) ")"

expectedDate :: Schema.PGDate
expectedDate = unsafePartial do
  let year = fromJust (toEnum 2025)
  let month = fromJust (toEnum 6)
  let day = fromJust (toEnum 15)
  Schema.PGDate (canonicalDate year month day)

expectedTime :: Schema.PGTime
expectedTime = unsafePartial do
  let hour = fromJust (toEnum 14)
  let minute = fromJust (toEnum 30)
  let second = fromJust (toEnum 45)
  let millisecond = fromJust (toEnum 125)
  Schema.PGTime (Time hour minute second millisecond)

expectedHalfSecondTime :: Schema.PGTime
expectedHalfSecondTime = unsafePartial do
  let hour = fromJust (toEnum 14)
  let minute = fromJust (toEnum 30)
  let second = fromJust (toEnum 45)
  let millisecond = fromJust (toEnum 500)
  Schema.PGTime (Time hour minute second millisecond)

expectedTimestamp :: Schema.TimestampTZ
expectedTimestamp = unsafePartial do
  let year = fromJust (toEnum 2025)
  let month = fromJust (toEnum 1)
  let day = fromJust (toEnum 15)
  let hour = fromJust (toEnum 12)
  let minute = fromJust (toEnum 0)
  let second = fromJust (toEnum 0)
  let millisecond = fromJust (toEnum 0)
  Schema.TimestampTZ (DateTime (canonicalDate year month day) (Time hour minute second millisecond))

setupBehaviorTable :: PG.Connection -> Aff Unit
setupBehaviorTable conn = do
  _ <- PG.executeSimple (PG.SQL "DROP TABLE IF EXISTS behavior_values") conn
  _ <- PG.executeSimple (PG.SQL (Schema.createTableDDL @BehaviorTable)) conn
  pure unit

setupTxTable :: PG.Connection -> Aff Unit
setupTxTable conn = do
  _ <- PG.executeSimple (PG.SQL "DROP TABLE IF EXISTS behavior_tx") conn
  _ <- PG.executeSimple (PG.SQL (Schema.createTableDDL @TxTable)) conn
  pure unit

setupTemporalParamTable :: PG.Connection -> Aff Unit
setupTemporalParamTable conn = do
  _ <- PG.executeSimple (PG.SQL "DROP TABLE IF EXISTS behavior_temporal") conn
  _ <- PG.executeSimple (PG.SQL (Schema.createTableDDL @TemporalParamTable)) conn
  pure unit

pureSpec :: Spec Unit
pureSpec = do
  describe "Postgres schema metadata and deterministic SQL" do
    it "renders every public scalar, array, and nullable type name" do
      Schema.pgTypeName (Proxy :: Proxy Int) `shouldEqual` "INTEGER"
      Schema.pgTypeName (Proxy :: Proxy String) `shouldEqual` "TEXT"
      Schema.pgTypeName (Proxy :: Proxy Boolean) `shouldEqual` "BOOLEAN"
      Schema.pgTypeName (Proxy :: Proxy Number) `shouldEqual` "DOUBLE PRECISION"
      Schema.pgTypeName (Proxy :: Proxy BigInt) `shouldEqual` "BIGINT"
      Schema.pgTypeName (Proxy :: Proxy Schema.PGUUID) `shouldEqual` "UUID"
      Schema.pgTypeName (Proxy :: Proxy Schema.PGDate) `shouldEqual` "DATE"
      Schema.pgTypeName (Proxy :: Proxy Schema.PGTime) `shouldEqual` "TIME"
      Schema.pgTypeName (Proxy :: Proxy Schema.TimestampTZ) `shouldEqual` "TIMESTAMPTZ"
      Schema.pgTypeName (Proxy :: Proxy Schema.Point) `shouldEqual` "POINT"
      Schema.pgTypeName (Proxy :: Proxy Schema.TSVector) `shouldEqual` "TSVECTOR"
      Schema.pgTypeName (Proxy :: Proxy Schema.TSQuery) `shouldEqual` "TSQUERY"
      Schema.pgTypeName (Proxy :: Proxy Schema.Jsonb) `shouldEqual` "JSONB"
      Schema.pgTypeName (Proxy :: Proxy (Array Int)) `shouldEqual` "INTEGER[]"
      Schema.pgTypeName (Proxy :: Proxy (Maybe Int)) `shouldEqual` "INTEGER"

    it "reports nullability from Maybe only" do
      Schema.isNullable (Proxy :: Proxy (Maybe Int)) `shouldEqual` true
      Schema.isNullable (Proxy :: Proxy Int) `shouldEqual` false

    it "renders IF NOT EXISTS and DEFAULT VALUES DDL" do
      Schema.createTableDDLIfNotExists @BehaviorTable
        `shouldEqual` "CREATE TABLE IF NOT EXISTS behavior_values (id INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY PRIMARY KEY, name TEXT NOT NULL, optional_int INTEGER)"
      Schema.insertSQLFor @AllDefaultTable
        `shouldEqual` "INSERT INTO behavior_defaults DEFAULT VALUES RETURNING *"
      (Schema.into allDefaultTable # Schema.insert {} # Schema.toSQL)
        `shouldEqual` "INSERT INTO behavior_defaults DEFAULT VALUES"

    it "renders update entrypoint and all set-operation variants" do
      (Schema.update behaviorTable # Schema.set { name: "updated" } # Schema.where_ @"id = $id" # Schema.toSQL)
        `shouldEqual` "UPDATE behavior_values SET name = $1 WHERE id = $id"
      let left = Schema.from behaviorTable # Schema.select @"name"
      let right = Schema.from behaviorTable # Schema.select @"name"
      (left `Schema.intersectAll` right # Schema.toSQL)
        `shouldEqual` "(SELECT name FROM behavior_values) INTERSECT ALL (SELECT name FROM behavior_values)"
      (left `Schema.exceptAll` right # Schema.toSQL)
        `shouldEqual` "(SELECT name FROM behavior_values) EXCEPT ALL (SELECT name FROM behavior_values)"

    it "renders CTEs and merges their named parameters" do
      let adults = Schema.cte @"adults" (Schema.from behaviorTable # Schema.select @"name" # Schema.where_ @"optional_int > $age")
      let mainQuery = Schema.fromCTE @"adults" adults # Schema.select @"name"
      (Schema.with_ adults mainQuery # Schema.toSQL)
        `shouldEqual` "WITH adults AS (SELECT name FROM behavior_values WHERE optional_int > $age) SELECT name FROM adults"

    it "replaces repeated named parameters and preserves casts" do
      let replaced = Schema.replaceNamedParams 2
            [ { name: "id", value: unsafeToForeign 7 }
            , { name: "name", value: unsafeToForeign "Alice" }
            ]
            "id = $id::int OR parent_id = $id AND name = $name"
      replaced.sql `shouldEqual` "id = $3 OR parent_id = $3 AND name = $4"
      Array.length replaced.values `shouldEqual` 2
      Schema.stripCast "$id::uuid" `shouldEqual` "$id"

    it "decodes rows and rejects mismatched result shapes" do
      let decoded = Schema.decodeRows
            [ unsafeToForeign { id: 1, name: "ok" }
            , unsafeToForeign { id: 2, name: "also ok" }
            ] :: Either _ (Array { id :: Int, name :: String })
      decoded `shouldEqual` Right [ { id: 1, name: "ok" }, { id: 2, name: "also ok" } ]
      let bad = Schema.decodeRow (unsafeToForeign { id: "wrong" }) :: Either _ { id :: Int }
      bad `shouldSatisfy` isLeft
      let fractionalTime = Schema.decodeRow (unsafeToForeign { value: "14:30:45.5" }) :: Either _ { value :: Schema.PGTime }
      fractionalTime `shouldEqual` Right { value: expectedHalfSecondTime }

integrationSpec :: SpecT Aff PG.Connection Identity Unit
integrationSpec = do
  describe "How to use the public Postgres API" do
    it "reports query metadata and preserves heterogeneous and homogeneous parameters" \conn -> do
      result <- PG.query
        (PG.SQL "SELECT $1::int AS minimum, $2::int AS maximum, $3::double precision AS huge, $4::text AS first, $5::text AS second, $6::int[] AS integers")
        ( PG.param (bottom :: Int)
            <> PG.param (top :: Int)
            <> PG.param 1.5e200
            <> PG.params [ "first", "second" ]
            <> PG.param [ bottom :: Int, top :: Int ]
        )
        conn
      result.command `shouldEqual` "SELECT"
      result.count `shouldEqual` 1
      case Schema.decodeRows result.rows of
        Left errs -> throwError (error (show errs))
        Right rows -> rows `shouldEqual`
          [ { minimum: bottom :: Int
            , maximum: top :: Int
            , huge: 1.5e200
            , first: "first"
            , second: "second"
            , integers: [ bottom :: Int, top :: Int ]
            }
          ]

    it "round-trips UUID, JSON, date, time, timestamp, arrays, and bigint rows" \conn -> do
      uuid <- liftEffect UUID.genUUID
      result <- PG.query
        (PG.SQL "SELECT $1::uuid AS uuid, $2::jsonb AS document, $3::date AS event_date, $4::time AS event_time, $5::timestamptz AS event_at, $6::text[] AS tags, $7::bigint AS big")
        [ PG.toPGValue uuid
        , PG.toPGValue (unsafeToForeign { key: "value", nested: { count: 2 } })
        , PG.toPGValue "2025-06-15"
        , PG.toPGValue "14:30:45.125"
        , PG.toPGValue "2025-01-15T12:00:00.000Z"
        , PG.toPGValue [ "a", "b" ]
        , PG.toPGValue "9223372036854775807"
        ]
        conn
      case Schema.decodeRows result.rows of
        Left errs -> throwError (error (show errs))
        Right rows -> rows `shouldEqual`
          [ { uuid: Schema.PGUUID uuid
            , document: { key: "value", nested: { count: 2 } }
            , event_date: expectedDate
            , event_time: expectedTime
            , event_at: expectedTimestamp
            , tags: [ "a", "b" ]
            , big: BigInt.fromString "9223372036854775807" # unsafePartial fromJust
            }
          ]

    it "distinguishes query-one, unsafe exact-row, and no-row behavior" \conn -> do
      one <- PG.queryOneSimple (PG.SQL "SELECT 41::int AS value") conn
      case one of
        Nothing -> throwError (error "expected queryOneSimple row")
        Just row -> Schema.decodeRow row `shouldEqual` Right { value: 41 }
      exact <- PG.unsafe (PG.SQL "SELECT $1::int AS value") [ PG.toPGValue 42 ] conn
      Schema.decodeRow exact `shouldEqual` Right { value: 42 }
      missing <- PG.queryOneSimple (PG.SQL "SELECT 1 WHERE false") conn
      case missing of
        Nothing -> pure unit
        Just _ -> throwError (error "expected queryOneSimple to return Nothing")
      unsafeMissing <- try $ PG.unsafe (PG.SQL "SELECT 1 WHERE false") [] conn
      case unsafeMissing of
        Left _ -> pure unit
        Right _ -> throwError (error "expected unsafe to reject an empty result")

    it "returns affected rows including zero matches" \conn -> do
      setupBehaviorTable conn
      inserted <- PG.execute (PG.SQL "INSERT INTO behavior_values (name) VALUES ($1), ($2)") (PG.params [ "a", "b" ]) conn
      inserted `shouldEqual` 2
      updated <- PG.execute (PG.SQL "UPDATE behavior_values SET name = $1 WHERE name = $2") (PG.params [ "updated", "missing" ]) conn
      updated `shouldEqual` 0
      deleted <- PG.executeSimple (PG.SQL "DELETE FROM behavior_values") conn
      deleted `shouldEqual` 2

    it "executes typed queries, Maybe parameters, raw results, mutations, and decode errors" \conn -> do
      setupBehaviorTable conn
      rows <- (Typed.executeSql typedIntQuery { n: 7 } conn :: Aff (Either String (Array { n :: Int })))
      rows `shouldEqual` Right [ { n: 7 } ]
      nullable <- (Typed.executeSql typedMaybeQuery { value: Nothing } conn :: Aff (Either String (Array { value :: Maybe Int })))
      nullable `shouldEqual` Right [ { value: Nothing } ]
      raw <- Typed.executeSqlRaw typedIntQuery { n: 8 } conn
      raw.count `shouldEqual` 1
      one <- (Typed.executeSqlOne typedIntQuery { n: 9 } conn :: Aff (Either String (Maybe { n :: Int })))
      one `shouldEqual` Right (Just { n: 9 })
      noRows <- (Typed.executeSqlOne (sql $ combineBuilders "SELECT 1::int AS n WHERE false" "") {} conn :: Aff (Either String (Maybe { n :: Int })))
      noRows `shouldEqual` Right (Nothing :: Maybe { n :: Int })
      many <- (Typed.executeSqlOne (sql $ combineBuilders "SELECT generate_series(1, 2)::int AS n" "") {} conn :: Aff (Either String (Maybe { n :: Int })))
      many `shouldEqual` Right (Nothing :: Maybe { n :: Int })
      bad <- (Typed.executeSql typedBadDecodeQuery {} conn :: Aff (Either String (Array { n :: Int })))
      bad `shouldSatisfy` isLeft
      affected <- Typed.executeMutation typedMutationQuery { name: "typed" } conn
      affected `shouldEqual` 1

    it "uses schema wrappers as typed query parameters" \conn -> do
      setupTemporalParamTable conn
      uuid <- liftEffect UUID.genUUID
      let pgUuid = Schema.PGUUID uuid
      let document = unsafeToForeign { key: "value", nested: { count: 2 } }
      _ <- PG.execute
        (PG.SQL "INSERT INTO behavior_temporal (document, event_at, event_date, event_time, label, uuid) VALUES ($1, $2, $3, $4, $5, $6)")
        [ PG.toPGValue document
        , PG.toPGValue "2025-01-15T12:00:00.000Z"
        , PG.toPGValue "2025-06-15"
        , PG.toPGValue "14:30:45.125"
        , PG.toPGValue "matched"
        , PG.toPGValue (UUID.toString uuid)
        ]
        conn
      byDate <- Schema.from temporalParamTable
        # Schema.select @"label"
        # Schema.where_ @"event_date = $date"
        # Schema.runQuery conn { date: expectedDate }
      byTime <- Schema.from temporalParamTable
        # Schema.select @"label"
        # Schema.where_ @"event_time = $time"
        # Schema.runQuery conn { time: expectedTime }
      byTimestamp <- Schema.from temporalParamTable
        # Schema.select @"label"
        # Schema.where_ @"event_at = $timestamp"
        # Schema.runQuery conn { timestamp: expectedTimestamp }
      byDocument <- Schema.from temporalParamTable
        # Schema.select @"label"
        # Schema.where_ @"document @> $document"
        # Schema.runQuery conn { document: Schema.Jsonb document }
      byDate `shouldEqual` [ { label: "matched" } ]
      byTime `shouldEqual` [ { label: "matched" } ]
      byTimestamp `shouldEqual` [ { label: "matched" } ]
      byDocument `shouldEqual` [ { label: "matched" } ]
      inserted <- Schema.into temporalParamTable
        # Schema.insert
            { document: Schema.Jsonb document
            , event_at: expectedTimestamp
            , event_date: expectedDate
            , event_time: expectedTime
            , label: "typed"
            , uuid: pgUuid
            }
        # Schema.runExecute conn {}
      inserted `shouldEqual` 1
      allRows <- PG.querySimple (PG.SQL "SELECT label FROM behavior_temporal ORDER BY label") conn
      decoded <- case Schema.decodeRows allRows.rows of
        Left errs -> throwError (error (show errs))
        Right values -> pure values
      decoded `shouldEqual` [ { label: "matched" }, { label: "typed" } ]

    it "converts Just values through the inner field encoder" \conn -> do
      setupTemporalParamTable conn
      uuid <- liftEffect UUID.genUUID
      let document = unsafeToForeign { key: "nullable timestamp" }
      inserted <- Schema.into temporalParamTable
        # Schema.insert
            { document: Schema.Jsonb document
            , event_at: expectedTimestamp
            , event_date: expectedDate
            , event_time: expectedTime
            , label: "nullable"
            , optional_event_at: Just expectedTimestamp
            , uuid: Schema.PGUUID uuid
            }
        # Schema.runExecute conn {}
      inserted `shouldEqual` 1
      rows <- Schema.from temporalParamTable
        # Schema.select @"optional_event_at"
        # Schema.runQuery conn {}
      rows `shouldEqual` [ { optional_event_at: Just expectedTimestamp } ]

    it "use begin/commit/rollback when transaction boundaries are explicit" \conn -> do
      setupTxTable conn
      committed <- PG.begin conn
      _ <- PG.txExecute (PG.SQL "INSERT INTO behavior_tx (name) VALUES ($1)") [ PG.toPGValue "committed" ] committed
      inTransaction <- PG.txQuery (PG.SQL "SELECT name FROM behavior_tx WHERE name = $1") [ PG.toPGValue "committed" ] committed
      inTransaction.count `shouldEqual` 1
      PG.commit committed
      afterCommit <- PG.querySimple (PG.SQL "SELECT name FROM behavior_tx") conn
      afterCommit.count `shouldEqual` 1

      rolledBack <- PG.begin conn
      _ <- PG.txExecute (PG.SQL "INSERT INTO behavior_tx (name) VALUES ($1)") [ PG.toPGValue "rolled back" ] rolledBack
      PG.rollback rolledBack
      afterRollback <- PG.querySimple (PG.SQL "SELECT name FROM behavior_tx") conn
      afterRollback.count `shouldEqual` 1


    it "let transaction roll back SQL errors and return the connection to the pool" \conn -> do
      setupTxTable conn
      result <- try $ PG.withTransaction (\txn -> do
        _ <- PG.txExecute (PG.SQL "INSERT INTO behavior_tx (name) VALUES ($1)") [ PG.toPGValue "before error" ] txn
        _ <- PG.txExecute (PG.SQL "INSERT INTO missing_behavior_table VALUES ($1)") [ PG.toPGValue 1 ] txn
        pure unit
        ) conn
      result `shouldSatisfy` isLeft
      rows <- PG.querySimple (PG.SQL "SELECT * FROM behavior_tx") conn
      rows.count `shouldEqual` 0
      PG.ping conn >>= (_ `shouldEqual` true)

    it "preserves the action failure when rollback also fails" \conn -> do
      result <- try $ PG.withTransaction
        (\txn -> do
          liftEffect $ poisonRollback txn
          throwError (error "action failed")
        )
        conn
      case result of
        Left cause -> message cause `shouldEqual` "action failed"
        Right _ -> throwError (error "expected transaction to fail")
      PG.ping conn >>= (_ `shouldEqual` true)

    it "let transaction roll back cancellation and return the connection to the pool" \conn -> do
      setupTxTable conn
      wrote <- liftEffect $ Ref.new false
      fiber <- forkAff $ PG.withTransaction
        (\txn -> do
          _ <- PG.txExecute
            (PG.SQL "INSERT INTO behavior_tx (name) VALUES ($1)")
            [ PG.toPGValue "cancelled" ]
            txn
          liftEffect $ Ref.write true wrote
          delay (Milliseconds 10000.0)
        )
        conn
      delay (Milliseconds 50.0)
      didWrite <- liftEffect $ Ref.read wrote
      didWrite `shouldEqual` true
      killFiber (error "cancel transaction") fiber
      rows <- PG.querySimple (PG.SQL "SELECT * FROM behavior_tx") conn
      rows.count `shouldEqual` 0
      PG.ping conn >>= (_ `shouldEqual` true)

    it "releases the reserved connection when commit itself fails" \_ -> do
      own <- liftEffect $ PG.postgres
        { host: PG.PostgresHost "localhost"
        , port: PG.PostgresPort 5434
        , database: PG.PostgresDatabase "test_playground"
        , username: PG.PostgresUsername "postgres"
        , password: PG.PostgresPassword "postgres"
        , max: PG.MaxConnections 1
        }
      _ <- PG.executeSimple (PG.SQL "DROP TABLE IF EXISTS behavior_commit_failure") own
      _ <- PG.executeSimple
        (PG.SQL "CREATE TABLE behavior_commit_failure (name TEXT UNIQUE DEFERRABLE INITIALLY DEFERRED)")
        own
      txn <- PG.begin own
      _ <- PG.txExecute
        (PG.SQL "INSERT INTO behavior_commit_failure (name) VALUES ($1), ($2)")
        [ PG.toPGValue "duplicate", PG.toPGValue "duplicate" ]
        txn
      commitResult <- try $ PG.commit txn
      commitResult `shouldSatisfy` isLeft
      PG.ping own >>= (_ `shouldEqual` true)
      PG.end own


    it "supports deterministic concurrent pool queries" \conn -> do
      setupBehaviorTable conn
      counts <- parTraverse
        (\n -> PG.execute (PG.SQL "INSERT INTO behavior_values (name) VALUES ($1)") [ PG.toPGValue ("worker-" <> show n) ] conn)
        (Array.range 1 8)
      counts `shouldEqual` Array.replicate 8 1
      rows <- PG.querySimple (PG.SQL "SELECT * FROM behavior_values") conn
      rows.count `shouldEqual` 8

    it "delivers notifications and actually unsubscribes" \conn -> do
      received <- liftEffect $ Ref.new ([] :: Array String)
      let channel = PG.Channel "behavior_notifications"
      PG.listen channel (\notification -> Ref.modify_ (_ <> [ notification.payload ]) received) conn
      PG.notify channel "before-unlisten" conn
      delay (Milliseconds 100.0)
      liftEffect (Ref.read received) >>= (_ `shouldEqual` [ "before-unlisten" ])
      PG.unlisten channel conn
      PG.notify channel "after-unlisten" conn
      delay (Milliseconds 100.0)
      liftEffect (Ref.read received) >>= (_ `shouldEqual` [ "before-unlisten" ])

    it "rejects missing and deallocated prepared statements" \conn -> do
      setupBehaviorTable conn
      let name = PG.StatementName "behavior_insert"
      missing <- try $ PG.executePrepared name [ PG.toPGValue "x" ] conn
      case missing of
        Left _ -> pure unit
        Right _ -> throwError (error "expected missing prepared statement to fail")
      PG.prepare name (PG.SQL "INSERT INTO behavior_values (name) VALUES ($1)") conn
      PG.executePrepared name [ PG.toPGValue "prepared" ] conn >>= (_.count >>> (_ `shouldEqual` 1))
      PG.deallocate name conn
      deallocated <- try $ PG.executePrepared name [ PG.toPGValue "again" ] conn
      case deallocated of
        Left _ -> pure unit
        Right _ -> throwError (error "expected deallocated prepared statement to fail")

    it "invokes notice and parameter callbacks as PureScript Effects" \_ -> do
      noticeSeen <- liftEffect $ Ref.new false
      parameterSeen <- liftEffect $ Ref.new false
      callbackConn <- liftEffect $ PG.postgres
        { host: PG.PostgresHost "localhost"
        , port: PG.PostgresPort 5434
        , database: PG.PostgresDatabase "test_playground"
        , username: PG.PostgresUsername "postgres"
        , password: PG.PostgresPassword "postgres"
        , onnotice: Ref.write true noticeSeen
        , onparameter: \_ -> Ref.write true parameterSeen
        }
      _ <- PG.executeSimple (PG.SQL "DO $$ BEGIN RAISE NOTICE 'behavior callback'; END $$") callbackConn
      _ <- PG.executeSimple (PG.SQL "SET application_name TO 'yoga-postgres-callback-test'") callbackConn
      liftEffect (Ref.read noticeSeen) >>= (_ `shouldEqual` true)
      liftEffect (Ref.read parameterSeen) >>= (_ `shouldEqual` true)
      PG.end callbackConn

    it "connects via connection string and end closes the pool" \_ -> do
      own <- liftEffect $ PG.postgres
        { connection: PG.ConnectionString "postgres://postgres:postgres@localhost:5434/test_playground" }
      PG.ping own >>= (_ `shouldEqual` true)
      PG.end own
      PG.ping own >>= (_ `shouldEqual` false)
