-- | Org-mode format parsing.

module OrgStat.Parser
       ( ParsingException (..)
       , parseOrg
       , runParser
       ) where

import           Control.Exception    (Exception)
import qualified Data.Attoparsec.Text as A
import qualified Data.OrgMode.Parse   as OP
import           Data.Time.Calendar   (fromGregorian)
import           Data.Time.Clock      (UTCTime (..), secondsToDiffTime)
import           Universum

import           OrgStat.Ast          (Clock (..), Org (..))

----------------------------------------------------------------------------
-- Exceptions
----------------------------------------------------------------------------

data ParsingException =
    ParsingException Text
    deriving (Show, Typeable)

instance Exception ParsingException

----------------------------------------------------------------------------
-- Parsing
----------------------------------------------------------------------------

parseOrg :: [Text] -> A.Parser Org
parseOrg todoKeywords = convertDocument <$> OP.parseDocument todoKeywords
  where
    convertDocument :: OP.Document -> Org
    convertDocument (OP.Document _ headings) = Org
        { _orgTitle    = ""
        , _orgTags     = []
        , _orgClocks   = []
        , _orgSubtrees = map convertHeading headings
        }

    convertHeading :: OP.Heading -> Org
    convertHeading heading = Org
        { _orgTitle    = OP.title heading
        , _orgTags     = OP.tags heading
        , _orgClocks   = getClocks $ OP.section heading
        , _orgSubtrees = map convertHeading $ OP.subHeadings heading
        }

    mapEither :: (a -> Either e b) -> ([a] -> [b])
    mapEither f xs = rights $ map f xs

    getClocks :: OP.Section -> [Clock]
    getClocks section =
        mapMaybe convertClock $ concat
        [ OP.sectionClocks section
        , mapEither (A.parseOnly OP.parseClock) $
          lines $
          OP.sectionParagraph section
        ]

    -- convert clocks from orgmode-parse format, returns Nothing for clocks
    -- without end time or time-of-day
    convertClock :: (Maybe OP.Timestamp, Maybe OP.Duration) -> Maybe Clock
    convertClock (Just (OP.Timestamp start _active (Just end)), _duration) =
        Clock <$> convertDateTime start <*> convertDateTime end
    convertClock _                                                 = Nothing

    -- Nothing for DateTime without time-of-day
    convertDateTime :: OP.DateTime -> Maybe UTCTime
    convertDateTime
        OP.DateTime
          { yearMonthDay = OP.YMD' (OP.YearMonthDay year month day)
          , hourMinute = Just (hour, minute)
          }
      = Just $ UTCTime
          (fromGregorian (toInteger year) month day)
          (secondsToDiffTime $ toInteger $ 60*(60*hour + minute))
    convertDateTime _ = Nothing

-- Throw parsing exception if it can't be parsed (use Control.Monad.Catch#throwM)
runParser :: (MonadThrow m) => Text -> m Org
runParser t = undefined
