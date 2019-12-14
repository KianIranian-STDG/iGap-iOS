//
//  IGThemeTVCell.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 12/14/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import SwiftEventBus

protocol handleTapOnCell {
    func didTapOnTheme(isClassic: Bool)
}
class IGThemeTVCell: UITableViewCell {
    
    @IBOutlet weak var collectionThemes : UICollectionView!
    var isClassicTheme : Bool = true
    var themeTypes = [IGStringsManager.ClassicTheme.rawValue.localized,IGStringsManager.DayTheme.rawValue.localized,IGStringsManager.NightTheme.rawValue.localized]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectTheme()
        initCollectionView()
    }
    
    private func initCollectionView() {
        self.collectionThemes.delegate = self
        self.collectionThemes.dataSource = self
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    private func selectTheme() {
        let currentTheme = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"

        switch currentTheme {
            
        case "IGAPClassic" :
            print("CURRENT  IS :","CLASSIC")
            self.isClassicTheme = true
            let indexPath = IndexPath(item: 0, section: 0)
            self.collectionThemes.selectItem(at: indexPath, animated: true, scrollPosition: [])
            break
            
        case "IGAPDay" :
            print("CURRENT  IS :","DAY")
            self.isClassicTheme = false
            let indexPath = IndexPath(item: 1, section: 0)
            self.collectionThemes.selectItem(at: indexPath, animated: true, scrollPosition: [])
            
            break
        case "IGAPNight" :
            print("CURRENT  IS :","NIGHT")
            self.isClassicTheme = false
            let indexPath = IndexPath(item: 2, section: 0)
            self.collectionThemes.selectItem(at: indexPath, animated: true, scrollPosition: [])
            
            break
            
        default:
            break
        }
    }
    
    
}
extension IGThemeTVCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IGThemeCVCell", for: indexPath) as! IGThemeCVCell
        let current = UserDefaults.standard.string(forKey: "CurrentTheme") ?? "IGAPClassic"
        
        cell.lblThemeName.text = themeTypes[indexPath.item]
        
        cell.viewBG.backgroundColor = DefaultColorSet().SettingClassicBG
        cell.viewSender.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: false)
        cell.viewReciever.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: true)
        
        
        
        switch indexPath.item {
        case 0 :
            cell.viewBG.backgroundColor = DefaultColorSet().SettingClassicBG
            cell.viewSender.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: false)
            cell.viewReciever.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: true)
            
            if current == "IGAPClassic" {
                cell.viewBG.layer.borderColor = ThemeManager.currentTheme.BorderColor.cgColor
                cell.viewReciever.backgroundColor = DefaultColorSet().SettingDayReceiveBubble
                
            } else if current == "IGAPDay" {
                cell.viewBG.layer.borderColor = UIColor.hexStringToUIColor(hex: "dedede").cgColor
                cell.viewReciever.backgroundColor = DayColorSetManager.currentColorSet.SettingDayReceiveBubble
                
                
            } else {
                cell.viewBG.layer.borderColor = UIColor.hexStringToUIColor(hex: "dedede").cgColor
                cell.viewReciever.backgroundColor = NightColorSetManager.currentColorSet.SettingDayReceiveBubble
                
                
            }
            
        case 1:
            cell.viewBG.backgroundColor = .white
            cell.viewSender.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: false)
            
            if current == "IGAPClassic" {
                cell.viewBG.layer.borderColor = ThemeManager.currentTheme.BorderColor.cgColor
                cell.viewReciever.backgroundColor = DefaultColorSet().SettingDayReceiveBubble
                
            } else if current == "IGAPDay" {
                cell.viewBG.layer.borderColor = UIColor.hexStringToUIColor(hex: "dedede").cgColor
                cell.viewReciever.backgroundColor = DayColorSetManager.currentColorSet.SettingDayReceiveBubble
                
                
            } else {
                cell.viewBG.layer.borderColor = UIColor.hexStringToUIColor(hex: "dedede").cgColor
                cell.viewReciever.backgroundColor = NightColorSetManager.currentColorSet.SettingDayReceiveBubble
                
                
            }
        case 2:
            cell.viewBG.backgroundColor = .black
            cell.viewSender.backgroundColor = UIColor.chatBubbleBackground(isIncommingMessage: false)
            
            cell.viewReciever.backgroundColor = DayColorSetManager.currentColorSet.SettingDayReceiveBubble
            if current == "IGAPClassic" {
                cell.viewBG.layer.borderColor = ThemeManager.currentTheme.BorderColor.cgColor
                cell.viewReciever.backgroundColor = DefaultColorSet().SettingDayReceiveBubble
                
            } else if current == "IGAPDay" {
                cell.viewBG.layer.borderColor = UIColor.hexStringToUIColor(hex: "dedede").cgColor
                cell.viewReciever.backgroundColor = DayColorSetManager.currentColorSet.SettingDayReceiveBubble
                
                
            } else {
                cell.viewBG.layer.borderColor = UIColor.hexStringToUIColor(hex: "dedede").cgColor
                cell.viewReciever.backgroundColor = NightColorSetManager.currentColorSet.SettingDayReceiveBubble
                
                
            }
        default :
            cell.viewBG.layer.borderColor = ThemeManager.currentTheme.BorderColor.cgColor
        }
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themeTypes.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemHeight = 108
        let itemWidth = UIScreen.main.bounds.width / 3
        return CGSize(width: Int(itemWidth), height: itemHeight)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
                let cell = collectionView.cellForItem(at: indexPath) as! IGThemeCVCell
                cell.viewBG.layer.borderColor = UIColor.iGapGreen().cgColor
                let currentColorSetLight = UserDefaults.standard.string(forKey: "CurrentColorSetLight")
                let currentColorSetDark = UserDefaults.standard.string(forKey: "CurrentColorSetDark")

                switch indexPath.item {
                case 0 :

                    UserDefaults.standard.set("IGAPClassic", forKey: "CurrentTheme")
                    print("CURRENT THEME IS :","Classic")
                    isClassicTheme = true
                    
                    ThemeManager.currentTheme = ClassicTheme()
                    SwiftEventBus.post("initTheme", sender: [isClassicTheme,"IGAPClassic","IGAPDefaultColor"])

                    
                case 1 :
                    UserDefaults.standard.set("IGAPDay", forKey: "CurrentTheme")
                    print("CURRENT THEME IS :","Day")
                    isClassicTheme = false
                    ThemeManager.currentTheme = DayTheme()

                    
                    
                case 2 :
                    UserDefaults.standard.set("IGAPNight", forKey: "CurrentTheme")
                    print("CURRENT THEME IS :","NIGHT")
                    isClassicTheme = false
                    ThemeManager.currentTheme = NightTheme()

                    
                default :
                    break
                }
        
        }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! IGThemeCVCell
        cell.viewBG.layer.borderColor = UIColor.hexStringToUIColor(hex: "dedede").cgColor

    }
}
