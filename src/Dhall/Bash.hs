{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE OverloadedStrings  #-}
{-# LANGUAGE QuasiQuotes        #-}

module Dhall.Bash where

import Control.Exception (Exception)
import Data.Bifunctor (first)
import Data.ByteString
import Data.Monoid ((<>))
import Data.Typeable (Typeable)
import Dhall.Core (Expr(..))
import Dhall.TypeCheck

import qualified Data.Foldable
import qualified Data.Map
import qualified Data.Text
import qualified Data.Text.Buildable
import qualified Data.Text.Encoding
import qualified Data.Text.Lazy
import qualified Data.Text.Lazy.Builder
import qualified Data.Vector
import qualified Dhall.Core
import qualified NeatInterpolation
import qualified Text.ShellEscape

_ERROR :: Data.Text.Text
_ERROR = "\ESC[1;31mError\ESC[0m"

data StatementError
    = UnsupportedStatement (Expr X X)
    | UnsupportedSubexpression (Expr X X)
    deriving (Typeable)

instance Show StatementError where
    show (UnsupportedStatement e) =
        Data.Text.unpack [NeatInterpolation.text|
$_ERROR: Cannot translate to a Bash statement

Explanation: Only primitive values, records, ❰List❱s, and ❰Optional❱ values can
be translated from Dhall to a Bash statement

The following Dhall expression could not be translated to a Bash statement:

↳ $txt
|]
      where
        txt = Data.Text.Lazy.toStrict (Dhall.Core.pretty e)
    show (UnsupportedSubexpression e) =
        -- Carefully note: No tip suggesting `--declare` since it won't work
        -- here (and the user is already using `--declare`)
        Data.Text.unpack [NeatInterpolation.text|
$_ERROR: Cannot translate to a Bash expression

Explanation: Only primitive values can be translated from Dhall to a Bash
expression

The following Dhall expression could not be translated to a Bash expression:

↳ $txt
|]
      where
        txt = Data.Text.Lazy.toStrict (Dhall.Core.pretty e)

instance Exception StatementError

data ExpressionError = UnsupportedExpression (Expr X X) deriving (Typeable)

instance Show ExpressionError where
    show (UnsupportedExpression e) =
        Data.Text.unpack [NeatInterpolation.text|
$_ERROR: Cannot translate to a Bash expression

Explanation: Only primitive values can be translated from Dhall to a Bash
expression

The following Dhall expression could not be translated to a Bash expression:

↳ $txt$tip
|]
      where
        txt = Data.Text.Lazy.toStrict (Dhall.Core.pretty e)

        tip = case e of
            OptionalLit _ _ -> "\n\n" <> [NeatInterpolation.text|
Tip: You can convert an ❰Optional❱ value to a Bash statement using the --declare
flag
|]
            ListLit _ _ -> "\n\n" <> [NeatInterpolation.text|
Tip: You can convert a ❰List❱ to a Bash statement using the --declare flag
|]
            RecordLit _ -> "\n\n" <> [NeatInterpolation.text|
Tip: You can convert a record to a Bash statement using the --declare flag
|]
            _ -> ""

instance Exception ExpressionError

dhallToStatement :: ByteString -> Expr s X -> Either StatementError ByteString
dhallToStatement var0 expr0 = go (Dhall.Core.normalize expr0)
  where
    var = Text.ShellEscape.bytes (Text.ShellEscape.bash var0)

    adapt (UnsupportedExpression e) = UnsupportedSubexpression e

    go (BoolLit a) = do
        go (TextLit (if a then "true" else "false"))
    go (NaturalLit a) = do
        go (IntegerLit (fromIntegral a))
    go (IntegerLit a) = do
        e <- first adapt (dhallToExpression (IntegerLit a))
        let bytes = "declare -r -i " <> var <> "=" <> e
        return bytes
    go (TextLit a) = do
        e <- first adapt (dhallToExpression (TextLit a))
        let bytes = "declare -r " <> var <> "=" <> e
        return bytes
    go (ListLit _ bs) = do
        bs' <- first adapt (mapM dhallToExpression bs)
        let bytes
                =   "declare -r -a "
                <>  var
                <>  "=("
                <>  Data.ByteString.intercalate " " (Data.Foldable.toList bs')
                <>  ")"
        return bytes
    go (OptionalLit _ bs) = do
        if Data.Vector.null bs
            then do
                let bytes = "unset " <> var
                return bytes
            else go (Data.Vector.head bs)
    go (RecordLit a) = do
        let process (k, v) = do
                v' <- dhallToExpression v
                let bytes = Data.Text.Encoding.encodeUtf8 (Data.Text.Lazy.toStrict k)
                let k'    = Text.ShellEscape.bytes (Text.ShellEscape.bash bytes)
                return ("[" <> k' <> "]=" <> v')
        kvs' <- first adapt (traverse process (Data.Map.toList a))
        let bytes
                =   "declare -r -A "
                <>  var
                <>  "=("
                <>  Data.ByteString.intercalate " " kvs'
                <>  ")"
        return bytes
    go e = Left (UnsupportedStatement e)

dhallToExpression:: Expr s X -> Either ExpressionError ByteString
dhallToExpression expr0 = go (Dhall.Core.normalize expr0)
  where
    go (BoolLit a) = do
        go (TextLit (if a then "true" else "false"))
    go (NaturalLit a) = do
        go (IntegerLit (fromIntegral a))
    go (IntegerLit a) = do
        go (TextLit (Data.Text.Buildable.build a))
    go (TextLit a) = do
        let text  = Data.Text.Lazy.Builder.toLazyText a
        let bytes = Data.Text.Encoding.encodeUtf8 (Data.Text.Lazy.toStrict text)
        return (Text.ShellEscape.bytes (Text.ShellEscape.bash bytes))
    go e = Left (UnsupportedExpression e)
