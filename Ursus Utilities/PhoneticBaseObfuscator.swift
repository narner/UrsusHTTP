//
//  PatObfuscator.swift
//  Alamofire
//
//  Created by Daniel Clelland on 26/06/20.
//

import Foundation
import BigInt
import Parity

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

    private static func feistelCipher(_ m: UInt32) -> UInt32 {
        return capFe(4, 0xFFFF, 0x10000, 0xFFFFFFFF, capF, m)
    }
    
    private static func reverseFeistelCipher(_ m: UInt32) -> UInt32 {
        return capFen(4, 0xFFFF, 0x10000, 0xFFFFFFFF, capF, m)
    }
    
}

extension PhoneticBaseObfuscator {
    
    private static func capF(_ j: Int, _ r: UInt32) -> UInt32 {
        let seeds: [UInt32] = [0xb76d5eed, 0xee281300, 0x85bcae01, 0x4b387af7]
        return muk(seeds[j], r)
    }
    
}

extension PhoneticBaseObfuscator {
    
    //-- | A specific murmur3 variant.
    //muk :: Word32 -> Word32 -> Word32
    //muk syd key = M.murmur3 syd kee where
    //  kee = chr lo `B8.cons` chr hi `B8.cons` mempty
    //  lo  = fromIntegral (key .&. 0xFF)
    //  hi  = fromIntegral (key .&. 0xFF00 `div` 0x0100)
    
    // https://github.com/aappleby/smhasher/blob/master/src/MurmurHash3.cpp
    // https://github.com/PeterScott/murmur3/blob/master/murmur3.c
    // https://github.com/jpedrosa/sua/blob/master/Sources/murmurhash3.swift
    // https://github.com/albacorelabs/murmurhash3/blob/master/Sources/murmurhash3/murmurhash3.swift
    // https://github.com/jwerle/murmurhash.c/blob/master/murmurhash.c
    
    private static func muk(_ seed: UInt32, _ key: UInt32) -> UInt32 {
        #warning("Finish `muk(_:_:)`")
        fatalError()
    }
    
}

extension PhoneticBaseObfuscator {
    
    private static func capFe(_ r: Int, _ a: UInt32, _ b: UInt32, _ k: UInt32, _ f: (_ j: Int, _ r: UInt32) -> UInt32, _ m: UInt32) -> UInt32 {
        let c = fe(r, a, b, f, m)
        return c < k ? c : fe(r, a, b, f, c)
    }
    
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
    
    private static func fe(_ r: Int, _ a: UInt32, _ b: UInt32, _ f: (_ j: Int, _ r: UInt32) -> UInt32, _ m: UInt32) -> UInt32 {
        #warning("Finish `fe(_:_:_:_:_:)`")
        return m
    }
    
}

extension PhoneticBaseObfuscator {
    
    private static func capFen(_ r: Int, _ a: UInt32, _ b: UInt32, _ k: UInt32, _ f: (_ j: Int, _ r: UInt32) -> UInt32, _ m: UInt32) -> UInt32 {
        let c = fen(r, a, b, f, m)
        return c <= k ? c : fen(r, a, b, f, c)
    }
    
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

    private static func fen(_ r: Int, _ a: UInt32, _ b: UInt32, _ f: (_ j: Int, _ r: UInt32) -> UInt32, _ m: UInt32) -> UInt32 {
        #warning("Finish `fen(_:_:_:_:_:)`")
        return m
    }
    
}
