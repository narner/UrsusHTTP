//
//  PatObfuscator.swift
//  Alamofire
//
//  Created by Daniel Clelland on 26/06/20.
//

import Foundation
import BigInt

internal struct PhoneticBaseObfuscator {

    internal static func obfuscate<T: UnsignedInteger>(_ value: T) -> T {
        switch value.bitWidth {
        case 17...32:
            let p32 = UInt32(value)
            return 0x10000 + T(feistelCipher(p32 - 0x10000))
        case 33...64:
            let low = value & 0x00000000FFFFFFFF
            let high = value & 0xFFFFFFFF00000000
            return high | obfuscate(low)
        default:
            return value
        }
    }

    internal static func deobfuscate<T: UnsignedInteger>(_ value: T) -> T {
        switch value.bitWidth {
        case 17...32:
            let p32 = UInt32(value)
            return 0x10000 + T(reverseFeistelCipher(p32 - 0x10000))
        case 33...64:
            let low = value & 0x00000000FFFFFFFF
            let high = value & 0xFFFFFFFF00000000
            return high | obfuscate(low)
        default:
            break
        }
        
        return value
    }
    
}

extension PhoneticBaseObfuscator {

    //-- | Generalised Feistel cipher.
    //--
    //--   See: Black and Rogaway (2002), "Ciphers with arbitrary finite domains."
    //--
    //--   Note that this has been adjusted from the reference paper in order to
    //--   support some legacy behaviour.
    //feis :: Word32 -> Word32
    //feis = capFe 4 0xFFFF 0x10000 0xFFFFFFFF capF

    internal static func feistelCipher(_ value: UInt32) -> UInt32 {
        return value
    }

    //-- | Reverse 'feis'.
    //--
    //--   See: Black and Rogaway (2002), "Ciphers with arbitrary finite domains."
    //--
    //--   Note that this has been adjusted from the reference paper in order to
    //--   support some legacy behaviour.
    //tail :: Word32 -> Word32
    //tail = capFen 4 0xFFFF 0x10000 0xFFFFFFFF capF
    
    internal static func reverseFeistelCipher(_ value: UInt32) -> UInt32 {
        return value
    }
    
    //-- | A PRF for j in [0, .., 3]
    //capF :: Int -> Word32 -> Word32
    //capF j key = fromIntegral (muk seed key) where
    //  seed = raku !! fromIntegral j
    //  raku = [
    //      0xb76d5eed
    //    , 0xee281300
    //    , 0x85bcae01
    //    , 0x4b387af7
    //    ]
    //
    //-- | 'Fe' in B&R (2002).
    //capFe
    //  :: Int
    //  -> Word32
    //  -> Word32
    //  -> Word32
    //  -> (Int -> Word32 -> Word32)
    //  -> Word32
    //  -> Word32
    //capFe r a b k f m
    //    | c < k     = c
    //    | otherwise = fe r a b f c
    //  where
    //    c = fe r a b f m
    //
    //-- | 'fe' in B&R (2002).
    //fe
    //  :: Int
    //  -> Word32
    //  -> Word32
    //  -> (Int -> Word32 -> Word32)
    //  -> Word32
    //  -> Word32
    //fe r a b f m = loop 1 capL capR where
    //  capL = m `mod` a
    //  capR = m `div` a
    //  loop j !ell !arr
    //    | j > r =
    //        if   odd r || arr == a
    //        then a * arr + ell
    //        else a * ell + arr
    //    | otherwise =
    //        let eff   = f (pred j) arr
    //            -- NB (jtobin):
    //            --
    //            -- note that the "extra" modulo operators here are not redundant as
    //            -- the addition of ell and eff can (silently) overflow Word32.
    //            -- modulo p does not distribute over addition, but it does
    //            -- "distribute modulo p," so this ensures we stay sufficiently
    //            -- small.
    //            tmp  = if   odd j
    //                   then (ell `mod` a + eff `mod` a) `mod` a
    //                   else (ell `mod` b + eff `mod` b) `mod` b
    //
    //        in  loop (succ j) arr tmp
    //
    //-- | 'Fen' in B&R (2002).
    //capFen
    //  :: Int
    //  -> Word32
    //  -> Word32
    //  -> Word32
    //  -> (Int -> Word32 -> Word32)
    //  -> Word32
    //  -> Word32
    //capFen r a b k f m
    //    | c <= k    = c
    //    | otherwise = fen r a b f c
    //  where
    //    c = fen r a b f m
    //
    //-- | 'fen' in B&R (2002).
    //fen
    //  :: Int
    //  -> Word32
    //  -> Word32
    //  -> (Int -> Word32 -> Word32)
    //  -> Word32
    //  -> Word32
    //fen r a b f m = loop r capL capR where
    //  ahh =
    //    if   odd r
    //    then m `div` a
    //    else m `mod` a
    //
    //  ale =
    //    if   odd r
    //    then m `mod` a
    //    else m `div` a
    //
    //  capL =
    //    if   ale == a
    //    then ahh
    //    else ale
    //
    //  capR =
    //    if   ale == a
    //    then ale
    //    else ahh
    //
    //  loop j !ell !arr
    //    | j < 1     = a * arr + ell
    //    | otherwise =
    //        let eff = f (pred j) ell
    //            -- NB (jtobin):
    //            --
    //            -- Slight deviation from B&R (2002) here to prevent negative
    //            -- values.  We add 'a' or 'b' to arr as appropriate and reduce
    //            -- 'eff' modulo the same number before performing subtraction.
    //            --
    //            tmp = if   odd j
    //                  then (arr + a - (eff `mod` a)) `mod` a
    //                  else (arr + b - (eff `mod` b)) `mod` b
    //        in  loop (pred j) tmp ell

    
}
