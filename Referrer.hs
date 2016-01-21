{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts  #-}

module Main where

import  Web.Scotty

main :: IO ()
main = scotty 80 $ do
   get "/" $ redirect "https://halosgho.st"
