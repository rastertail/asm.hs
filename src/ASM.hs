{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TupleSections #-}

module ASM where

import Control.Lens
import Control.Monad.State
-- import qualified Data.ByteString as B
import Data.ByteString.Builder
import Data.Word


data Module = Module {
    _loadAddr :: Int,
    _builder :: Builder,
    _len :: Int
} deriving (Show)
makeLenses ''Module

type AsmT m a = StateT Module m a
type Asm = AsmT Identity Int


label :: Monad m => AsmT m Int
label = gets (^.len)

scope :: Monad m => AsmT m a -> AsmT m Int
scope b = label >>= (<$ b)


write :: Monad m => Int -> Builder -> AsmT m Int
write l b = state $ \m -> (m^.len, len +~ l $ builder %~ (<> b) $ m)

byte :: Monad m => Word8 -> AsmT m Int
byte b = write 1 $ word8 b

bytes :: Monad m => [Word8] -> AsmT m Int
bytes b = write (length b) $ mconcat $ map word8 b


zeros :: Monad m => Int -> AsmT m Int
zeros l = bytes $ replicate l 0

align :: Monad m => Int -> AsmT m Int
align a = get >>= \m -> zeros $ a - rem (m^.len) a


relative :: Monad m => Int -> Int -> AsmT m Int
relative a b = gets (\_ -> b - a)

absolute :: Monad m => Int -> AsmT m Int
absolute a = gets (\m -> m^.loadAddr + a)


assemble :: Monad m => AsmT m a -> Int -> m Builder
assemble a l = (^.builder) <$> execStateT a Module { _loadAddr = l, _builder = mempty, _len = 0 }


test :: Asm
test = scope
    (mdo
        a <- byte 1
        align 8
        relative a b >>= \r -> write 1 $ int8 $ fromIntegral r
        b <- byte 1
        return ()
    )