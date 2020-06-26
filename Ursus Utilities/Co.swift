//
//  Co.swift
//  Alamofire
//
//  Created by Daniel Clelland on 26/06/20.
//

import Foundation
import BigInt
import Parity

public enum CoError: Error {
    
    case invalidPrefix(String)
    case invalidSuffix(String)
    
}

//-- | Convert a 'Natural' to \@p.
//--
//--   >>> patp 0
//--   ~zod
//--   >>> patp 256
//--   ~marzod
//--   >>> patp 65536
//--   ~dapnep-ronmyl
//--   >>> patp 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
//--   ~fipfes-fipfes-fipfes-fipfes--fipfes-fipfes-fipfes-fipfes
//--
//patp :: Natural -> Patp
//patp = Patp . BS.reverse . C.unroll . Ob.fein

//-- | Convert a \@p value to its corresponding 'Natural'.
//--
//--   >>> let zod = patp 0
//--   >>> fromPatp zod
//--   0
//--
//fromPatp :: Patp -> Natural
//fromPatp = Ob.fynd . C.roll . BS.reverse . unPatp

//-- | Render a \@p value as 'T.Text'.
//--
//--   >>> renderPatp (patp 0)
//--   "~zod"
//--   >>> renderPatp (patp 15663360)
//--   "~nidsut-tomdun"
//renderPatp :: Patp -> T.Text
//renderPatp (Patp bs) = render Padding LongSpacing bs

#warning("Finish obfuscation")

public struct PatP: CustomStringConvertible {
    
    internal var value: BigUInt

    internal init(_ value: BigUInt) {
        self.value = value
    }

    public init() {
        self.value = .zero
    }
    
    public init(string: String) throws {
        let bytes = try parse(string)
        self.init(BigUInt(Data(bytes)))
    }
    
    public var description: String {
        let bytes: [UInt8] = Array(value.serialize())
        return render(bytes: bytes, padding: .padding, spacing: .longSpacing)
    }
    
}

public struct PatQ: CustomStringConvertible {
    
    internal var value: BigUInt

    internal init(_ value: BigUInt) {
        self.value = value
    }

    public init() {
        self.value = .zero
    }
    
    public init(string: String) throws {
        let bytes = try parse(string)
        self.init(BigUInt(Data(bytes)))
    }
    
    public var description: String {
        let bytes: [UInt8] = Array(value.serialize())
        return render(bytes: bytes, padding: .noPadding, spacing: .shortSpacing)
    }
    
}

public enum Padding {
    
    case padding
    case noPadding
    
    func padCondition(bytes: [UInt8]) -> Bool {
        switch self {
        case .noPadding:
            return bytes.count == 0
        case .padding:
            return bytes.count == 0 || (bytes.count.isOdd && bytes.count > 2)
        }
    }
    
    func pad(bytes: [UInt8]) -> [UInt8] {
        if padCondition(bytes: bytes) {
            return [0] + bytes
        } else {
            return bytes
        }
    }
    
}

public enum Spacing {
    
    case longSpacing
    case shortSpacing
    
    var dash: String {
        switch self {
        case .longSpacing:
            return "--"
        case .shortSpacing:
            return "-"
        }
    }
    
}

public func render(bytes: [UInt8], padding: Padding, spacing: Spacing) -> String {
    return "~" + padding.pad(bytes: bytes).reversed().enumerated().reduce("") { result, element in
        let (index, byte) = element
        let syllable: String = {
            switch index.parity {
            case .even:
                return suffix(byte)
            case .odd:
                return prefix(byte)
            }
        }()
        
        let glue: String = {
            if index % 8 == 0 {
                return index == 0 ? "" : spacing.dash
            } else if index.isEven {
                return "-"
            } else {
                return ""
            }
        }()
        
        return syllable + glue + result
    }
    
}

public func parse(_ string: String) throws -> [UInt8] {
    let syllables = string.filter({ $0 != "~" && $0 != "-" }).chunked(by: 3)
    return try syllables.reversed().enumerated().reduce([]) { result, element in
        let (index, syllable) = element
        switch index.parity {
        case .even:
            return [try fromSuffix(syllable)] + result
        case .odd:
            return [try fromPrefix(syllable)] + result
        }
    }
}

internal let prefixes: [String] = ["doz", "mar", "bin", "wan", "sam", "lit", "sig", "hid", "fid", "lis", "sog", "dir", "wac", "sab", "wis", "sib",
                                   "rig", "sol", "dop", "mod", "fog", "lid", "hop", "dar", "dor", "lor", "hod", "fol", "rin", "tog", "sil", "mir",
                                   "hol", "pas", "lac", "rov", "liv", "dal", "sat", "lib", "tab", "han", "tic", "pid", "tor", "bol", "fos", "dot",
                                   "los", "dil", "for", "pil", "ram", "tir", "win", "tad", "bic", "dif", "roc", "wid", "bis", "das", "mid", "lop",
                                   "ril", "nar", "dap", "mol", "san", "loc", "nov", "sit", "nid", "tip", "sic", "rop", "wit", "nat", "pan", "min",
                                   "rit", "pod", "mot", "tam", "tol", "sav", "pos", "nap", "nop", "som", "fin", "fon", "ban", "mor", "wor", "sip",
                                   "ron", "nor", "bot", "wic", "soc", "wat", "dol", "mag", "pic", "dav", "bid", "bal", "tim", "tas", "mal", "lig",
                                   "siv", "tag", "pad", "sal", "div", "dac", "tan", "sid", "fab", "tar", "mon", "ran", "nis", "wol", "mis", "pal",
                                   "las", "dis", "map", "rab", "tob", "rol", "lat", "lon", "nod", "nav", "fig", "nom", "nib", "pag", "sop", "ral",
                                   "bil", "had", "doc", "rid", "moc", "pac", "rav", "rip", "fal", "tod", "til", "tin", "hap", "mic", "fan", "pat",
                                   "tac", "lab", "mog", "sim", "son", "pin", "lom", "ric", "tap", "fir", "has", "bos", "bat", "poc", "hac", "tid",
                                   "hav", "sap", "lin", "dib", "hos", "dab", "bit", "bar", "rac", "par", "lod", "dos", "bor", "toc", "hil", "mac",
                                   "tom", "dig", "fil", "fas", "mit", "hob", "har", "mig", "hin", "rad", "mas", "hal", "rag", "lag", "fad", "top",
                                   "mop", "hab", "nil", "nos", "mil", "fop", "fam", "dat", "nol", "din", "hat", "nac", "ris", "fot", "rib", "hoc",
                                   "nim", "lar", "fit", "wal", "rap", "sar", "nal", "mos", "lan", "don", "dan", "lad", "dov", "riv", "bac", "pol",
                                   "lap", "tal", "pit", "nam", "bon", "ros", "ton", "fod", "pon", "sov", "noc", "sor", "lav", "mat", "mip", "fip"]

internal func prefix(_ byte: UInt8) -> String {
    return prefixes[Int(byte)]
}

internal func fromPrefix(_ syllable: String) throws -> UInt8 {
    guard let byte = prefixes.firstIndex(of: syllable) else {
        throw CoError.invalidPrefix(syllable)
    }
    
    return UInt8(byte)
}

internal let suffixes: [String] = ["zod", "nec", "bud", "wes", "sev", "per", "sut", "let", "ful", "pen", "syt", "dur", "wep", "ser", "wyl", "sun",
                                   "ryp", "syx", "dyr", "nup", "heb", "peg", "lup", "dep", "dys", "put", "lug", "hec", "ryt", "tyv", "syd", "nex",
                                   "lun", "mep", "lut", "sep", "pes", "del", "sul", "ped", "tem", "led", "tul", "met", "wen", "byn", "hex", "feb",
                                   "pyl", "dul", "het", "mev", "rut", "tyl", "wyd", "tep", "bes", "dex", "sef", "wyc", "bur", "der", "nep", "pur",
                                   "rys", "reb", "den", "nut", "sub", "pet", "rul", "syn", "reg", "tyd", "sup", "sem", "wyn", "rec", "meg", "net",
                                   "sec", "mul", "nym", "tev", "web", "sum", "mut", "nyx", "rex", "teb", "fus", "hep", "ben", "mus", "wyx", "sym",
                                   "sel", "ruc", "dec", "wex", "syr", "wet", "dyl", "myn", "mes", "det", "bet", "bel", "tux", "tug", "myr", "pel",
                                   "syp", "ter", "meb", "set", "dut", "deg", "tex", "sur", "fel", "tud", "nux", "rux", "ren", "wyt", "nub", "med",
                                   "lyt", "dus", "neb", "rum", "tyn", "seg", "lyx", "pun", "res", "red", "fun", "rev", "ref", "mec", "ted", "rus",
                                   "bex", "leb", "dux", "ryn", "num", "pyx", "ryg", "ryx", "fep", "tyr", "tus", "tyc", "leg", "nem", "fer", "mer",
                                   "ten", "lus", "nus", "syl", "tec", "mex", "pub", "rym", "tuc", "fyl", "lep", "deb", "ber", "mug", "hut", "tun",
                                   "byl", "sud", "pem", "dev", "lur", "def", "bus", "bep", "run", "mel", "pex", "dyt", "byt", "typ", "lev", "myl",
                                   "wed", "duc", "fur", "fex", "nul", "luc", "len", "ner", "lex", "rup", "ned", "lec", "ryd", "lyd", "fen", "wel",
                                   "nyd", "hus", "rel", "rud", "nes", "hes", "fet", "des", "ret", "dun", "ler", "nyr", "seb", "hul", "ryl", "lud",
                                   "rem", "lys", "fyn", "wer", "ryc", "sug", "nys", "nyl", "lyn", "dyn", "dem", "lux", "fed", "sed", "bec", "mun",
                                   "lyr", "tes", "mud", "nyt", "byr", "sen", "weg", "fyr", "mur", "tel", "rep", "teg", "pec", "nel", "nev", "fes"]

internal func suffix(_ byte: UInt8) -> String {
    return suffixes[Int(byte)]
}

internal func fromSuffix(_ syllable: String) throws -> UInt8 {
    guard let byte = suffixes.firstIndex(of: syllable) else {
        throw CoError.invalidSuffix(syllable)
    }
    
    return UInt8(byte)
}
