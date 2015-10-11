{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE FlexibleContexts  #-}

module Main where

import qualified Web.Scotty                           as Web
import qualified Data.Text                            as Text
import           Lucid.Base
import           Lucid.Html5
import           Network.Wai.Middleware.RequestLogger (logStdoutDev)
import           Network.Wai.Middleware.Static        (addBase, noDots
                                                      ,staticPolicy, (>->))

main :: IO ()
main = Web.scotty 8080 $ do
   Web.middleware $ staticPolicy (noDots >-> addBase "assets")
   Web.middleware logStdoutDev

   Web.get "/assets/:file" $ do
           f <- Web.param "file"
           Web.file $ mconcat ["assets/",f]

   Web.get "/" $ Web.html . renderText $ doctypehtml_ $ do
         head_ $ do title_ "/home/halosghost"
                    css
         body_ $ do
             h1_ "Sam Stuewe (halosghost)"
             h2_ "Background"
             p_ $ mconcat
                [ "Though most of my personal projects are end-user "
                , "facing, almost all my personal programming "
                , "experience is in lower-level languages (primarily "
                , "C11 and Haskell2010). I also have, in the past, "
                , "worked with several higher-level languages "
                , "(including Java, Python and Lua)."
                ]
             p_ $ mconcat
                [ "I have been a Linux user for some time now, and "
                , "feel very comfortable on the command-line. I am "
                , "also quite familiar with administration and "
                , "maintenance for Windows, OSX and Linux (and even "
                , "a little with BSD and Plan9)."
                ]
             p_ $ do "My full CV may be found "
                     a_ [href_ "/assets/cv.pdf"] "here"
                     "."
             h2_ "Projects"
             p_ $ do "Though "; code_ "shaman"; " and "; code_ "pbpst"
                     " are fairly stable, none of these projects are complete; "
                     "there are still many more things I would like to "
                     "implement in all of them."
             ul_ $ do
               li_ $ do gh "shaman" "shaman"
                        ", an unassuming cli weather program"
               li_ $ do gh "pbpst" "pbpst"
                        ", a simple, but featureful pastebin client for "
                        a_ [href_ "https://github.com/ptpb/pb"] "pb"
                        " deployments"
               li_ $ do gh "adarcroom" "adarcroom"
                        ", a C/ncurses port of "
                        a_ [href_ adr] "A Dark Room"
               li_ $ do gh "stratagem" "stratagem"
                        ", a Hakell/Brick clone of the board game"
               li_ $ do gh ".bin" "bin"
                        ", a set of small, helpful utils"
               li_ $ do gh ".dotfiles" "dotfiles"
                        ", my Linux configuration files"
             h2_ "Academic Work"
             p_ $ mconcat
                [ "I graduated with Latin and departmental honors from "
                , a_ [href_ "http://macalester.edu/"] "Macalester"
                , " class of 2014, receiving a Bachelor of Arts degree "
                , "in Political Science. You can view the full text of "
                , "my honors' thesis on my "
                , gh "honors_thesis" "GitHub"
                , "."
                ]
             hr_ []
             footer_ $ p_ $ do "Sam Stuewe © 2014–2015. See the source of this "
                               "website "; gh "halosgho.st" "here"; "."
                               a_ [href_ "http://www.catb.org/hacker-emblem"] $ do
                                  img_ [src_ "/assets/hlogo.png"]
     where gh n n' = a_ [href_ $ mconcat [b, n]] n'
           b = "https://github.com/HalosGhost/"
           adr = "http://adarkroom.doublespeakgames.com/"
           css = style_ $ Text.intercalate " "
               [ "body {"
               ,   "margin: 5% 15%;"
               , "}"
               , "img {"
               ,   "float: right;"
               , "}"
               , "li {"
               ,   "margin-bottom: 1em;"
               , "}"
               ]
