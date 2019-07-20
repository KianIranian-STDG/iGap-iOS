//
//  IGFavouriteChannelsDashboardInnerTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 7/20/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import SwiftyJSON

class IGFavouriteChannelsDashboardInnerTableViewController: UITableViewController {
    var galleryImageUrlArray : [String] = []
    var FirstSliderImageArray : [UIImage?] = []
    var SecondSliderImageArray : [UIImage?] = []
    var channelsList: [channels] = []

    var scale : String = "8:4"
    var playbackTime : Int = 2000
    var showSlider = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.register(SliderTypeOneCell.nib, forCellReuseIdentifier: SliderTypeOneCell.identifier)
        tableView?.register(SliderTypeThreeCell.nib, forCellReuseIdentifier: SliderTypeThreeCell.identifier)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }

    // MARK: - Table view data source


    func getData() {
        guard let data = IGGlobal.dataFromFile("ServerDataInner") else {
            return
        }
        if galleryImageUrlArray.count > 0 {
            galleryImageUrlArray.removeAll()
        }
        //swiftyJSON
        if let json = try? JSON(data: data) {
  
            let tmpJsonI = json["info"]
            let tmpJsonII = json["channels"].arrayValue
            let tmpJsonIII = json["pagination"].dictionaryObject
 

            if let hasAdd = json["info"]["has_ad"].bool {
                if hasAdd {
                    showSlider = true
                    //slider Images
                    scale = json["info"]["advertisement"]["scale"].stringValue
                    playbackTime = json["info"]["advertisement"]["playback_time"].intValue
                    let advertisment = json["info"]["advertisement"]["slides"].arrayValue
                    for elemnt in advertisment {
                        let tmpIMGurl = (elemnt["image_url"]).description
                        galleryImageUrlArray.append(tmpIMGurl)
                    }
                    
                    //channels
                    let tmpChannels = json["channels"].arrayValue

                    for elemnt in tmpChannels {
                        let tmpIconUrl = (elemnt["icon"]).description
                        let tmpTitleEn = (elemnt["titleEn"]).description
                        let tmpTitleFa = (elemnt["title"]).description
                        let tmpId = (elemnt["id"]).description

                        let t = channels(titleEn: tmpTitleEn, titleFa: tmpTitleFa, id: tmpId, iconUrl: tmpIconUrl)
                        channelsList.append(t)
                    }
                    
                } else {
                    showSlider = false
                    //channels
                    let tmpChannels = json["channels"].arrayValue
                    
                    for elemnt in tmpChannels {
                        let tmpIconUrl = (elemnt["icon"]).description
                        let tmpTitleEn = (elemnt["titleEn"]).description
                        let tmpTitleFa = (elemnt["title"]).description
                        let tmpId = (elemnt["id"]).description
                        
                        let t = channels(titleEn: tmpTitleEn, titleFa: tmpTitleFa, id: tmpId, iconUrl: tmpIconUrl)
                        channelsList.append(t)
                    }
                    
                }
            }

            
        }
        
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        if showSlider {
            return 2

        } else {
            return 1

        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if showSlider {
            
            switch indexPath.section {
            case 0 :
                let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeOneCell", for: indexPath as IndexPath) as! SliderTypeOneCell
                
                cell.initViewInner(scale: scale, loopTime: playbackTime / 1000 , imageUrl : galleryImageUrlArray)
                return cell
                
                break
            case 1 :
                let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeThreeCell", for: indexPath as IndexPath) as! SliderTypeThreeCell
                cell.isInnenr = true

                cell.channelsList = channelsList
                cell.initViewInner()
                //            cell.categoriesDataArray = galleryCategoriesDataArray
                
                //            cell.initView()
                
                return cell
                
                break
            default :
                let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeOneCell", for: indexPath as IndexPath) as! SliderTypeOneCell
                return cell
                
                break
                
            }
        } else {
            
            switch indexPath.section {

            case 0 :
                let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeThreeCell", for: indexPath as IndexPath) as! SliderTypeThreeCell
                cell.isInnenr = true
                cell.channelsList = channelsList

                cell.initViewInner()

                return cell
                
                break
            default :
                let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeThreeCell", for: indexPath as IndexPath) as! SliderTypeThreeCell
                cell.isInnenr = true
                cell.channelsList = channelsList

                cell.initViewInner()

                return cell
                break
                
            }
            
        }
    }
    
    
}
