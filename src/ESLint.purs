module ESLint
  ( verify
  , createCLIEngine
  , createLinter
  , executeOnText
  , parser
  , CLIEngine
  , FileName(..)
  , SourceCode(..)
  , Linter
  , LinterConfig
  , LintOptions
  , LintMessage
  , Message
  , NodeType
  , Range
  , RuleId
  , Severity
  , Fix
  ) where

import Prelude
import Control.Monad.Except (runExcept)
import Data.Either (Either)
import Data.Function.Uncurried (Fn3, Fn5, runFn3, runFn5)
import Data.List.Types (NonEmptyList)
import Data.Maybe (Maybe)
import Data.Options (Option, Options, opt)
import Data.Traversable (traverse)
import Data.Tuple (Tuple)
import Effect (Effect)
import Foreign (F, Foreign, ForeignError(..), fail, readArray, readBoolean, readInt, readNullOrUndefined, readString)
import Foreign.Index ((!))

foreign import data ESLint :: Type

foreign import data Linter :: Type

foreign import data CLIEngine :: Type

foreign import data RuleTester :: Type

foreign import eslint :: Effect ESLint

newtype RuleId
  = RuleId String

derive newtype instance showRuleId :: Show RuleId

type Message
  = String

newtype NodeType
  = NodeType String

data LinterConfig

parser :: Option LinterConfig String
parser = opt "espree"

data LintOptions

type LintMessage
  = { column :: Int
    , line :: Int
    , endColumn :: Maybe Int
    , endLine :: Maybe Int
    , ruleId :: Maybe RuleId
    , message :: String
    , nodeType :: NodeType
    , fatal :: Maybe Boolean
    , severity :: Severity
    -- , fix :: Maybe Fix
    , source :: Maybe String
    }

newtype SourceCode
  = SourceCode String

newtype Severity
  = Severity Int

derive newtype instance showSeverity :: Show Severity

derive newtype instance showNodeType :: Show NodeType

type Range
  = Tuple Int Int

data Fix
  = Fix
    { text :: String
    , range :: Range
    }

foreign import verifyImpl ::
  forall r.
  Fn5
    (String -> r)
    (Foreign -> r)
    Linter
    (Options LinterConfig)
    SourceCode
    r

readMessage :: Foreign -> F LintMessage
readMessage value = do
  column <- value ! "column" >>= readInt
  line <- value ! "line" >>= readInt
  endColumn <- value ! "endColumn" >>= readNullOrUndefined >>= traverse readInt
  endLine <- value ! "endLine" >>= readNullOrUndefined >>= traverse readInt
  ruleId <- value ! "ruleId" >>= readNullOrUndefined >>= traverse readString <#> map RuleId
  message <- value ! "message" >>= readString
  nodeType <- value ! "nodeType" >>= readString <#> NodeType
  fatal <- value ! "fatal" >>= readNullOrUndefined >>= traverse readBoolean
  severity <- value ! "severity" >>= readInt <#> Severity
  source <- value ! "source" >>= readNullOrUndefined >>= traverse readString
  pure
    { column
    , line
    , endColumn
    , endLine
    , ruleId
    , message
    , nodeType
    , fatal
    , severity
    , source
    }

type LintMessages
  = (Array LintMessage)

verify ::
  Linter ->
  Options LinterConfig ->
  SourceCode ->
  Either (NonEmptyList ForeignError) (Array LintMessage)
verify linter linterConfig sourceCode =
  runExcept
    $ traverse readMessage
    =<< readArray
    =<< value
  where
  readForeignValue :: Linter -> Options LinterConfig -> SourceCode -> F Foreign
  readForeignValue = runFn5 verifyImpl (fail <<< ForeignError) pure

  value = readForeignValue linter linterConfig sourceCode

foreign import createLinter :: Unit -> Linter

foreign import createCLIEngine :: Unit -> CLIEngine

newtype FileName
  = FileName String

type ErrorWarningCounts
  = ( errorCount :: Int
    , warningCount :: Int
    , fixableErrorCount :: Int
    , fixableWarningCount :: Int
    )

type LintResult
  = { filePath :: String
    , messages :: Array LintMessage
    -- , output :: Maybe String
    -- , source :: Maybe String
    | ErrorWarningCounts
    }

type LintReport
  = { results :: Array LintResult
    | ErrorWarningCounts
    }

foreign import executeOnTextImpl :: Fn3 CLIEngine SourceCode FileName LintReport

executeOnText :: CLIEngine -> SourceCode -> FileName -> LintReport
executeOnText = runFn3 executeOnTextImpl

foreign import createRuleTester :: RuleTester
