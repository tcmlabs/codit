module Main where

import Prelude
import Data.Either (Either(..))
import Data.Options ((:=))
import ESLint (CLIEngine, FileName(..), Linter, SourceCode(..))
import ESLint as ESLint
import Effect (Effect)
import Effect.Console (logShow)

linter :: Linter
linter = ESLint.createLinter unit

cliEngine :: CLIEngine
cliEngine = ESLint.createCLIEngine unit

code :: SourceCode
code = SourceCode "var foo = 1"

testLinterVerify :: Effect Unit
testLinterVerify = do
  case messages of
    Left err -> logShow $ err
    Right m -> logShow $ m
  where
  config = (ESLint.parser := "espree")

  messages = ESLint.verify linter config code

testCLIEngine :: Effect Unit
testCLIEngine = do
  logShow $ messages
  where
  messages = ESLint.executeOnText cliEngine code filename

  filename = FileName "foo.js"

main :: Effect Unit
main = testLinterVerify
