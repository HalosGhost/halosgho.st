{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts  #-}

module Main where

import  Web.Scotty

secHdrs :: ActionM ()
secHdrs = do setHeader "content-security-policy"
                       "default-src 'self'"
             setHeader "x-frame-options"
                       "DENY"
             setHeader "x-xss-protection"
                       "1; mode=block"
             setHeader "x-content-type-options"
                       "nosniff"

main :: IO ()
main = scotty 80 $ do
   get "/" $ do secHdrs; redirect "https://halosgho.st"
