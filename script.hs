#!/usr/bin/env nix-shell
#!nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/nixpkgs-unstable.tar.gz
#!nix-shell --pure
#!nix-shell --keep TELEGRAM_TOKEN
#!nix-shell --keep TELEGRAM_CHAT_ID
#!nix-shell deps.nix -i runhaskell
-- Start of script
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}

import Control.Monad (void)
import Data.String (fromString)
import Network.HTTP.Client.TLS (newTlsManager)
import System.Environment (getEnv)
import Web.Telegram.API.Bot
import Data.Int (Int64)

main :: IO ()
main = do
  token <- getEnv "TELEGRAM_TOKEN"
  chatId <- read @Int64 <$> getEnv "TELEGRAM_CHAT_ID"
  manager <- newTlsManager
  void . runTelegramClient (Token (fromString token)) manager $
    sendMessageM (SendMessageRequest (ChatId chatId) "Some text" Nothing Nothing (Just True) Nothing Nothing)
