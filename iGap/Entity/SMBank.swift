//
//  SMswift
//  PayGear
//
//  Created by a on 4/11/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//






class SMBank: SMEntity {
    
    static let ENTITY_NAME = "Bank"
    
    var key:UInt?
    var nameEN:String?
    var nameFA:String?
    var isPartner:Bool?
    var services:String?
    var bins:String?
    var order:Int32?
    var logoRes:String?
    var vGradient1Color:String?
    var vGradient2Color:String?
    var vTextColor:String?
    var vPanColor:String?
    var vGradientDegree:Int32?
    var color:UInt?
    
    
    
    
    func setBankInfo(code : Int64) {
        
        switch (code) {
        case 1: //parsian
            key = 1
            nameFA = IGStringsManager.BankParsian.rawValue.localized
            logoRes = "bank_logo_parsian"
            color = 0xFF92000e
            break
        case 2: //saman
            
            key = 2
            nameFA = IGStringsManager.BankSaman.rawValue.localized
            logoRes = "bank_logo_saman"
            color = 0xFF2ab1ea
            //    backgroundDrawable = getBack(color)
            break
        case 3: //mellat
            
            key = 3
            nameFA = IGStringsManager.BankMellat.rawValue.localized
            logoRes = "bank_logo_mellat"
            color = 0xFFa7002f
            //    backgroundDrawable = getBack(color)
            break
        case 4: //eghtesad novin
            
            key = 4
            nameFA = IGStringsManager.BankEqtesadNovin.rawValue.localized
            logoRes = "bank_logo_eghtesad_novin"
            color = 0xFFBEA4C7
            //    backgroundDrawable = getBack(color)
            break
        case 5: //pasargad
            
            key = 5
            nameFA = IGStringsManager.BankPasargad.rawValue.localized
            logoRes = "bank_logo_pasargad"
            color = 0xFF797676
            //    backgroundDrawable = getBack(color)
            break
        case 6: //karafarin
            
            key = 6
            nameFA = IGStringsManager.BankKarafarin.rawValue.localized
            logoRes = "bank_logo_karafarin"
            color = 0xFF90B39D
            //    backgroundDrawable = getBack(color)
            break
        case 7: //sarmayeh
            
            key = 7
            nameFA = IGStringsManager.BankSarmaye.rawValue.localized
            logoRes = "bank_logo_sarmayeh"
            color = 0xFFA3AEBE
            //    backgroundDrawable = getBack(color)
            break
        case 8: //melli
            
            key = 8
            nameFA = IGStringsManager.BankMelli.rawValue.localized
            logoRes = "bank_logo_melli"
            color = 0xFF8BA3DC
            //    backgroundDrawable = getBack(color)
            break
        case 9: //sepah
            
            key = 9
            nameFA = IGStringsManager.BankSepah.rawValue.localized
            logoRes = "bank_logo_sepah"
            color = 0xFF94B1D6
            //    backgroundDrawable = getBack(color)
            break
        case 10: //dey
            
            key = 10
            nameFA = IGStringsManager.BankDey.rawValue.localized
            logoRes = "bank_logo_dey"
            color = 0xFF74B1BF
            //    backgroundDrawable = getBack(color)
            break
        case 11: //tejarat
            
            key = 11
            nameFA = IGStringsManager.BankTejarat.rawValue.localized
            logoRes = "bank_logo_tejarat"
            color = 0xFF94BEE2
            //    backgroundDrawable = getBack(color)
            break
        case 12: //refah
            
            key = 12
            
            nameFA = IGStringsManager.BankRefah.rawValue.localized
            logoRes = "bank_logo_refah"
            color = 0xFF959BB4
            //    backgroundDrawable = getBack(color)
            break
        case 13: //saderat
            
            key = 13
            nameFA = IGStringsManager.BankSaderat.rawValue.localized
            logoRes = "bank_logo_saderat"
            color = 0xFF93BAD6
            //    backgroundDrawable = getBack(color)
            break
        case 14: //maskan
            
            key = 14
            nameFA = IGStringsManager.BankMaskan.rawValue.localized
            logoRes = "bank_logo_maskan"
            color = 0xFFDAB68C
            //    backgroundDrawable = getBack(color)
            break
        case 15: //shahr
            
            key = 15
            nameFA = IGStringsManager.BankShahr.rawValue.localized
            logoRes = "bank_logo_shahr"
            color = 0xFFE19196
            //    backgroundDrawable = getBack(color)
            break
        case 16: //sina
            
            key = 16
            nameFA = IGStringsManager.BankSina.rawValue.localized
            logoRes = "bank_logo_sina"
            color = 0xFF94BEE2
            //    backgroundDrawable = getBack(color)
            break
        case 17: //keshavarzi
            
            key = 17
            nameFA = IGStringsManager.BankKeshavarzi.rawValue.localized
            logoRes = "bank_logo_keshavarzi"
            color = 0xFFD1C78A
            //    backgroundDrawable = getBack(color)
            break
        case 18: //markazi
            
            key = 18
            nameFA = IGStringsManager.BankMarkazi.rawValue.localized
            logoRes = "bank_logo_markazi"
            color = 0xFF97A1D6
            //    backgroundDrawable = getBack(color)
            break
        case 19: //gardeshgari
            
            key = 19
            nameFA = IGStringsManager.BankGardeshgari.rawValue.localized
            logoRes = "bank_logo_gardeshgari"
            color = 0xFFE6767D
            //    backgroundDrawable = getBack(color)
            break
        case 20: //post bank
            
            key = 20
            nameFA = IGStringsManager.BankPost.rawValue.localized
            logoRes = "bank_logo_post"
            color = 0xFF81B67D
            //    backgroundDrawable = getBack(color)
            break
        case 21: //ansar
            
            key = 21
            nameFA = IGStringsManager.BankAnsar.rawValue.localized
            logoRes = "bank_logo_ansar"
            color = 0xFFBFB174
            //    backgroundDrawable = getBack(color)
            break
        case 22: //iran zamin
            
            key = 22
            nameFA = IGStringsManager.BankIranzamin.rawValue.localized
            logoRes = "bank_logo_iran_zamin"
            color = 0xFFCAA4DC
            //    backgroundDrawable = getBack(color)
            break
        case 23: //ayandeh
            
            key = 23
            nameFA = IGStringsManager.BankAyandeh.rawValue.localized
            
            logoRes = "bank_logo_ayandeh"
            color = 0xFFBF9D74
            //    backgroundDrawable = getBack(color)
            break
        case 24: //resalat
            
            key = 24
            nameFA = IGStringsManager.BankResalat.rawValue.localized
            logoRes = "bank_logo_resalat"
            color = 0xFF97C0CA
            //    backgroundDrawable = getBack(color)
            break
        case 25: //tosee taavon
            
            key = 25
            nameFA = IGStringsManager.BankToseeTaavon.rawValue.localized
            logoRes = "bank_logo_tosee_taavon"
            color = 0xFF99C4C9
            //    backgroundDrawable = getBack(color)
            break
        case 26: //tosee saderat
            
            key = 26
            nameFA = IGStringsManager.BankToseeSaderat.rawValue.localized
            logoRes = "bank_logo_tosee_saderat"
            color = 0xFF92B691
            //    backgroundDrawable = getBack(color)
            break
        case 27: //hekmat iranian
            
            key = 27
            nameFA = IGStringsManager.BankHekmat.rawValue.localized
            logoRes = "bank_logo_hekmat_iranian"
            color = 0xFF89A3E9
            //    backgroundDrawable = getBack(color)
            break
        case 28: //sanat o madan
            
            key = 28
            nameFA = IGStringsManager.BankSanatMadan.rawValue.localized
            logoRes = "bank_logo_sanato_madan"
            color = 0xFF95B0D9
            //    backgroundDrawable = getBack(color)
            break
        case 29: //ghavamin
            
            key = 29
            nameFA = IGStringsManager.BankQavamin.rawValue.localized
            logoRes = "bank_logo_ghavamin"
            color = 0xFF74A776
            //    backgroundDrawable = getBack(color)
            break
        case 30: //mehr iran
            
            key = 30
            nameFA = IGStringsManager.BankMehrIran.rawValue.localized
            logoRes = "bank_logo_mehr_iran"
            color = 0xFFA4C79D
            //    backgroundDrawable = getBack(color)
            break
        case 31: //mehr eghtesad
            
            key = 31
            nameFA = IGStringsManager.BankMehrEqtesad.rawValue.localized
            logoRes = "bank_logo_mehr_eghtesad"
            color = 0xFFA4C79D
            //    backgroundDrawable = getBack(color)
            break
        case 32: //etebari kosar
            
            key = 32
            nameFA = IGStringsManager.BankKosar.rawValue.localized
            logoRes = "bank_logo_etebari_kosar"
            color = 0xFFCC8581
            //    backgroundDrawable = getBack(color)
            break
        case 33: //etebari tosee
            
            key = 33
            nameFA = IGStringsManager.BankEtebariTosee.rawValue.localized
            logoRes = "bank_logo_etebari_tosee"
            color = 0xFFB36C70
            //    backgroundDrawable = getBack(color)
            break
        case 34: //etebari asgarieh
            
            key = 34
            
            nameFA = IGStringsManager.BankMelal.rawValue.localized
            logoRes = "bank_logo_etebari_asgarieh"
            color = 0xFF8998BF
            //    backgroundDrawable = getBack(color)
            break
        case 69: //paygear
            
            key = 69
            nameFA = IGStringsManager.PaygearCard.rawValue.localized
            logoRes = ""
            color = 0xffffff
            //    backgroundDrawable = getBack(color)
            break
            
        default:
            nameFA = IGStringsManager.PaygearCard.rawValue.localized
            logoRes = ""
            color = 0xffffff
        }
    }
    
    
    static func getBankLogo(bankCodeNumber : String?)->String{
        switch (bankCodeNumber) {
        case "622106"?: //parsian
            return bankLogos.parsian.rawValue
        case "621986"?: //saman
            return bankLogos.saman.rawValue
        case "610433"?: //mellat
            return bankLogos.melat.rawValue
        case "627412"?: //eghtesad novin
            return bankLogos.novin.rawValue
        case "502229"?: //pasargad
            return bankLogos.pasargad.rawValue
        case "639347"?:
            return bankLogos.pasargad.rawValue
        case "627488"?: //karafarin
            return bankLogos.karafarin.rawValue
        case "639607"?: //sarmayeh
            return bankLogos.sarmaye.rawValue
        case "603799"?: //melli
            return bankLogos.melli.rawValue
        case "589210"?: //sepah
            return bankLogos.sepah.rawValue
        case "502938"?: //dey
            return bankLogos.dey.rawValue
        case "627353"?: //tejarat
            return bankLogos.tejarat.rawValue
        case "589463"?: //refah
            return bankLogos.refah.rawValue
        case "603769"?: //saderat
            return bankLogos.saderat.rawValue
        case "628023"?: //maskan
            return bankLogos.maskan.rawValue
        case "502806"?: //shahr
            return bankLogos.shahr.rawValue
        case "639346"?: //sina
            return bankLogos.sina.rawValue
        case "603770"?: //keshavarzi
            return bankLogos.keshavarzi.rawValue
        case "636795"?: //markazi
            return bankLogos.markazi.rawValue
        case "505416"?: //gardeshgari
            return bankLogos.gardeshgari.rawValue
        case "627760"?: //post bank
            return bankLogos.postBank.rawValue
        case "627381"?: //ansar
            return bankLogos.ansar.rawValue
        case "505785"?: //iran zamin
            return bankLogos.iranZamin.rawValue
        case "636214"?: //ayandeh
            return bankLogos.ayandeh.rawValue
        case "504172"?: //resalat
            return bankLogos.resalat.rawValue
        case "502908"?: //tosee taavon
            return bankLogos.tosee_taavon.rawValue
        case "627648"?: //tosee saderat
            return bankLogos.tosee_saderat.rawValue
        case "207177"?:
            return bankLogos.tosee_saderat.rawValue
        case "636949"?: //hekmat iranian
            return bankLogos.hekmat.rawValue
        case "627961"?: //sanat o madan
            return bankLogos.sanato_madan.rawValue
        case "639599"?: //ghavamin
            return bankLogos.ghavamin.rawValue
        case "606373"?: //mehr iran
            return bankLogos.mehrIran.rawValue
        case "639370"?: //mehr eghtesad
            return bankLogos.mehrEghtesad.rawValue
        case "505801"?: //etebari kosar
            return bankLogos.kosar.rawValue
        case "628157"?: //etebari tosee
            return bankLogos.etebariTosee.rawValue
        case "606256"?: //etebari asgarieh
            return bankLogos.asgariyeh.rawValue
        default:
            return bankLogos.paygear.rawValue
            
            
            
        }
        
        
    }
    
    
    
}
