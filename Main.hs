{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts  #-}

module Main where

import qualified Web.Scotty                           as Web
import           Lucid.Base
import           Lucid.Html5
import           Network.Wai.Middleware.RequestLogger (logStdoutDev)
import           Network.Wai.Middleware.Gzip          (gzip, gzipFiles, def
                                                      ,GzipFiles(GzipCompress))
import           Network.Wai.Middleware.Static        (addBase, noDots
                                                      ,staticPolicy, (>->))

main :: IO ()
main = Web.scotty 8080 $ do
   Web.middleware $ gzip $ def { gzipFiles = GzipCompress }
   Web.middleware $ staticPolicy (noDots >-> addBase "assets")
   Web.middleware logStdoutDev

   Web.get "/assets/:file" $ do
           f <- Web.param "file"
           Web.setHeader "cache-control" "public, max-age=604800"
           Web.file $ mconcat ["assets/",f]

   Web.get "/" $ do
     Web.setHeader "cache-control" "public, max-age=1800"
     Web.html . renderText $ do
       doctype_; html_ [lang_ "en"] $ do
         head_ $ do title_ "/home/halosghost"
                    meta_ [charset_ "utf-8"]
                    meta_ [name_ "viewport"
                          ,content_ "width=device-width, initial-scale=1"]
         body_ [style_ "margin: 5% 15%;"] $ do
             h1_ "Sam Stuewe (halosghost)"
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
               style_ "li { margin-bottom: 1em; }"
               li_ $ do gh "shaman" "shaman"; ", a simple cli weather program"
               li_ $ do gh "pbpst" "pbpst"
                        ", a simple, but featureful pastebin client for "
                        a_ [href_ "https://github.com/ptpb/pb"] "pb"
                        " deployments"
               li_ $ do gh "adarcroom" "adarcroom"; ", a C/ncurses port of "
                        a_ [href_ adr] "A Dark Room"
               li_ $ do gh "stratagem" "stratagem"
                        ", a Hakell/Brick clone of the board game"
               li_ $ do gh ".bin" "bin"; ", a set of small, helpful utils"
               li_ $ do gh ".dotfiles" "dotfiles"; ", my Linux configurations"
             h2_ "Academic Work"
             p_ $ do "I graduated with Latin and departmental honors from "
                     a_ [href_ "http://macalester.edu/"] "Macalester"
                     " class of 2014, receiving a Bachelor of Arts degree in "
                     "Political Science. You can view the full text of my "
                     "honors' thesis on my "; gh "honors_thesis" "GitHub"; "."
             hr_ []
             footer_ $ p_ $ do "Sam Stuewe © 2014–2015. See the source of this "
                               "website "; gh "halosgho.st" "here"; "."
                               a_ [href_ "http://www.catb.org/hacker-emblem"] $
                                  img_ [ src_ "/assets/hlogo.png"
                                       , style_ "float: right;"
                                       ]
     where gh n n' = a_ [href_ $ mconcat [b, n]] n'
           b       = "https://github.com/HalosGhost/"
           adr     = "http://adarkroom.doublespeakgames.com/"
