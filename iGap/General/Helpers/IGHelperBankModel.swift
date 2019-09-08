/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */
import UIKit

enum bankLogos : String{
    case parsian = "bank_logo_parsian"
    case saman = "bank_logo_saman"
    case melat = "bank_logo_mellat"
    case novin = "bank_logo_eghtesad_novin"
    case pasargad = "bank_logo_pasargad"
    case karafarin = "bank_logo_karafarin"
    case sarmaye = "bank_logo_sarmayeh"
    case melli = "bank_logo_melli"
    case sepah = "bank_logo_sepah"
    case dey = "bank_logo_dey"
    case tejarat = "bank_logo_tejarat"
    case refah = "bank_logo_refah"
    case saderat = "bank_logo_saderat"
    case maskan = "bank_logo_maskan"
    case shahr = "bank_logo_shahr"
    case sina = "bank_logo_sina"
    case keshavarzi = "bank_logo_keshavarzi"
    case markazi = "bank_logo_markazi"
    case gardeshgari = "bank_logo_gardeshgari"
    case postBank = "bank_logo_post_bank"
    case ansar = "bank_logo_ansar"
    case iranZamin = "bank_logo_iran_zamin"
    case ayandeh = "bank_logo_ayandeh"
    case resalat = "bank_logo_resalat"
    case tosee_taavon = "bank_logo_tosee_taavon"
    case tosee_saderat = "bank_logo_tosee_saderat"
    case hekmat = "bank_logo_hekmat_iranian"
    case sanato_madan = "bank_logo_sanato_madan"
    case ghavamin = "bank_logo_ghavamin"
    case mehrIran = "bank_logo_mehr_iran"
    case mehrEghtesad = "bank_logo_mehr_eghtesad"
    case kosar = "bank_logo_etebari_kosar"
    case etebariTosee = "bank_logo_etebari_tosee"
    case asgariyeh = "bank_logo_etebari_asgarieh"
    case paygear = "paygear_logo_wide"
    
}




class BankModel {
    

    
    func setBankInfo(code : Int64) {
        
        switch (code) {
        case 1: //parsian
           
            break
        case 2: //saman
            
            
            break
        case 3: //mellat
            

            break
        case 4: //eghtesad novin
            

            break
        case 5: //pasargad
            
            break
        case 6: //karafarin

            break
        case 7: //sarmayeh

            break
        case 8: //melli

            break
        case 9: //sepah
            

            break
        case 10: //dey
            

            break
        case 11: //tejarat
            

            break
        case 12: //refah
            
   
            break
        case 13: //saderat
            

            break
        case 14: //maskan

            break
        case 15: //shahr

            break
        case 16: //sina

            break
        case 17: //keshavarzi
            

            break
        case 18: //markazi
            
            break
        case 19: //gardeshgari
            
            break
        case 20: //post bank
            
            break
        case 21: //ansar
            
            break
        case 22: //iran zamin
            
            break
        case 23: //ayandeh
            
            break
        case 24: //resalat
            
            break
        case 25: //tosee taavon
            
            break
        case 26: //tosee saderat
            
            break
        case 27: //hekmat iranian
            
            break
        case 28: //sanat o madan
            
            break
        case 29: //ghavamin
            
            break
        case 30: //mehr iran
            
            break
        case 31: //mehr eghtesad
            
            break
        case 32: //etebari kosar
            
            break
        case 33: //etebari tosee
            
            break
        case 34: //etebari asgarieh
            
            break
        case 69: //paygear
            
            break
            
        default:
            break
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
