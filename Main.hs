{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts  #-}

module Main where

import qualified Web.Scotty                           as Web
import qualified Web.Scotty.TLS                       as Web
import           Lucid.Base
import           Lucid.Html5
import qualified Lucid.Svg                            as Svg
import           Network.Wai.Middleware.RequestLogger (logStdoutDev)
import           Network.Wai.Middleware.ETag          (etag, defaultETagContext
                                                      ,MaxAge(..))
import           Network.Wai.Middleware.Gzip          (gzip, gzipFiles, def
                                                      ,GzipFiles(GzipCompress))
import           Network.Wai.Middleware.Static        (addBase, noDots
                                                      ,staticPolicy, (>->))
import qualified Network.TLS                          as TLS
import           Network.TLS.Extra                    as TLSExtra
import           Network.Wai.Handler.WarpTLS          (certFile, keyFile
                                                      ,defaultTlsSettings
                                                      ,tlsAllowedVersions
                                                      ,tlsCiphers
                                                      ,keyFile, TLSSettings(..))

tlsSet :: TLSSettings
tlsSet = defaultTlsSettings
  { keyFile  = "/etc/ssl/private/halosgho.st.pem"
  , certFile = "/etc/ssl/certs/halosgho.st.crt"
  , tlsAllowedVersions = [TLS.TLS12]
  , tlsCiphers =
    [ TLSExtra.cipher_ECDHE_RSA_AES128GCM_SHA256
    , TLSExtra.cipher_ECDHE_ECDSA_AES128GCM_SHA256
    , TLSExtra.cipher_ECDHE_RSA_AES128CBC_SHA
    , TLSExtra.cipher_DHE_RSA_AES256_SHA256
    , TLSExtra.cipher_AES256_SHA256
    , TLSExtra.cipher_AES256_SHA1
    ]
  }

secHdrs :: Web.ActionM ()
secHdrs = do
  Web.setHeader "strict-transport-security" "max-age=31536000;includeSubDomains"
  Web.setHeader "content-security-policy"   "default-src 'self'"
  Web.setHeader "x-frame-options"           "SAMEORIGIN"
  Web.setHeader "x-xss-protection"          "1;mode=block"
  Web.setHeader "x-content-type-options"    "nosniff"

hlogo :: Svg.Svg ()
hlogo = Svg.svg11_ $ do
  Svg.symbol_ [ Svg.id_ "hlogo", Svg.viewBox_ "0 0 20 20"
              , Svg.preserveAspectRatio_ "xMinYMin"] $ do
    Svg.rect_ [Svg.x_ "35%", Svg.y_ "0%",  Svg.width_ "30%", Svg.height_ "30%"]
    Svg.rect_ [Svg.x_ "70%", Svg.y_ "35%", Svg.width_ "30%", Svg.height_ "30%"]
    Svg.rect_ [Svg.x_ "0%",  Svg.y_ "70%", Svg.width_ "30%", Svg.height_ "30%"]
    Svg.rect_ [Svg.x_ "35%", Svg.y_ "70%", Svg.width_ "30%", Svg.height_ "30%"]
    Svg.rect_ [Svg.x_ "70%", Svg.y_ "70%", Svg.width_ "30%", Svg.height_ "30%"]

header :: Html ()
header = head_ $ do
  title_ "/home/halosghost"
  meta_ [charset_ "utf-8"]
  meta_ [name_ "viewport", content_ "width=device-width,initial-scale=1"]
  link_ [rel_ "stylesheet", type_ "text/css", href_ "/assets/main.css"]

handleRoot :: Web.ScottyM ()
handleRoot = Web.get "/" $ do
  secHdrs
  Web.html . renderText $ do
    doctype_; html_ [lang_ "en"] $ do
      header
      body_ [id_ "main"] $ do
        header_ $ h1_ "Sam Stuewe (halosghost)"
        main_ $ do
          h2_ "Background"
          p_ $ do "Though most of my personal projects are end-user facing, "
                  "almost all my personal programming experience is in "
                  "lower-level languages (primarily C11 and Haskell2010). "
                  "I also have, in the past, worked with several "
                  "higher-level languages (including Java, Python and Lua)."
          p_ $ do "I have been a Linux user for some time now, and feel "
                  "very comfortable on the command-line. I am also quite "
                  "familiar with administration and maintenance for Windows"
                  ", OSX and Linux (and even a little with BSD and Plan9)."
          p_ $ do "My full CV may be found "
                  a_ [href_ "/assets/cv.pdf"] "here"; "."
          h2_ "Projects"
          p_ $ do "Though "; code_ "shaman"; " and "; code_ "pbpst"
                  " are fairly stable, none of these projects are complete; "
                  "there are still many more things I would like to "
                  "implement in all of them."
          ul_ $ do
            li_ $ do gh "shaman" "shaman"; ", a simple cli weather program"
            li_ $ do gh "pbpst" "pbpst"
                     ", a simple, but featureful pastebin client for "
                     a_ [href_ "https://github.com/ptpb/pb"] "pb"
                     " deployments"
            li_ $ do gh "adarcroom" "adarcroom"; ", a C/ncurses port of "
                     a_ [href_ adr] "A Dark Room"
            li_ $ do gh "stratagem" "stratagem"
                     ", a Haskell/Brick clone of the board game"
            li_ $ do gh ".bin" "bin"; ", a set of small, helpful utils"
            li_ $ do gh ".dotfiles" "dotfiles"; ", my Linux configurations"
          h2_ "Academic Work"
          p_ $ do "I graduated with Latin and departmental honors from "
                  a_ [href_ "http://macalester.edu/"] "Macalester"
                  " class of 2014, receiving a Bachelor of Arts degree in "
                  "Political Science. You can view the full text of my "
                  "honors' thesis on my "; gh "honors_thesis" "GitHub"; "."
        footer_ $ do p_ [id_ "runner"] $ do
                      "Sam Stuewe © 2014–2015. See the source of this "
                      "website "; gh "halosgho.st" "here"; "."
                     hLink $ Svg.with pLg [Svg.width_ "20", Svg.height_ "20"]
        hlogo
  where gh n n' = a_ [href_ $ mconcat [b, n]] n'
        b       = "https://github.com/HalosGhost/"
        adr     = "http://adarkroom.doublespeakgames.com/"
        pLg     = Svg.svg11_ $ Svg.use_ [Svg.xlinkHref_ "#hlogo"]
        hLink   = a_ [id_ "hlink", href_ target]
        target  = "http://www.catb.org/hacker-emblem/"

handleFiles :: Web.ScottyM ()
handleFiles = do
  Web.get "/media/:file" $ do
    f <- Web.param "file"; secHdrs; Web.file $ mconcat ["media/",f]

  Web.get "/assets/:file" $ do
    f <- Web.param "file"; secHdrs; Web.file $ mconcat ["assets/",f]

main :: IO ()
main = defaultETagContext True >>= \ctx -> Web.scottyTLSSettings 443 tlsSet $ do
  Web.middleware logStdout
  Web.middleware . gzip $ def { gzipFiles = GzipCompress }
  Web.middleware . staticPolicy $ noDots >-> addBase "assets"
  Web.middleware . etag ctx $ MaxAgeSeconds 604800

  handleFiles
  handleRoot
