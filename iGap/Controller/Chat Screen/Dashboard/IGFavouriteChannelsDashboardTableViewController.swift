//
//  IGFavouriteChannelsDashboardTableViewController.swift
//  iGap
//
//  Created by BenyaminMokhtarpour on 7/15/19.
//  Copyright © 2019 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD

class IGFavouriteChannelsDashboardTableViewController: UITableViewController {

    var sectionArrays : [String?] = []
    var galleryLoopTimeArray : [Int] = []
    var galleryImageUrlArray : [[String]] = [[]]
    var galleryChannelsDataArray : [[channels]] = [[]]
    var sectionTitleArrays : [String] = []
    var sectionTitleEnArrays : [String] = []
    var galleryScaleArray : [String] = []
    var FirstSliderImageArray : [UIImage?] = []
    var SecondSliderImageArray : [UIImage?] = []
    var hud = MBProgressHUD()
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.register(SliderTypeOneCell.nib, forCellReuseIdentifier: SliderTypeOneCell.identifier)
        tableView?.register(SliderTypeTwoCell.nib, forCellReuseIdentifier: SliderTypeTwoCell.identifier)
        tableView?.register(SliderTypeThreeCell.nib, forCellReuseIdentifier: SliderTypeThreeCell.identifier)

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshOnCall(_:)), name: (NSNotification.Name(rawValue: SMConstants.refreshTableView)), object: nil)

        getData()
    }
    
    @objc func refreshOnCall(_ nofication: Notification)  {
        self.tableView.reloadData()
    }
    public func dataFromFile(_ filename: String) -> Data? {
        @objc class TestClass: NSObject { }
        
        let bundle = Bundle(for: TestClass.self)
        if let path = bundle.path(forResource: filename, ofType: "json") {
            return (try? Data(contentsOf: URL(fileURLWithPath: path)))
        }
        return nil
    }
    

    func getData() {
        guard let data = dataFromFile("ServerData") else {
            return
        }
        
        if galleryImageUrlArray.count > 0 {
            galleryImageUrlArray.removeAll()
        }
        
        //swiftyJSON
        if let json = try? JSON(data: data) {
            for elemnt in json["data"].arrayValue {
                let tmpType = (elemnt["type"]).description
                sectionArrays.append(tmpType)

                let tmpInfo = (elemnt["info"])
                let tmpFATitle = (tmpInfo["title"])
                let tmpENTitle = (tmpInfo["titleEn"])
                sectionTitleArrays.append(tmpFATitle.description)
                sectionTitleEnArrays.append(tmpENTitle.description)
                if tmpInfo["scale"].exists() {
                    galleryScaleArray.append(tmpInfo["scale"].description)
                }
                else {
                    galleryScaleArray.append("")
                }
                if tmpInfo["playback_time"].exists() {
                    galleryLoopTimeArray.append((tmpInfo["playback_time"].intValue)/1000)
                }
                else {
                    galleryLoopTimeArray.append(1)
                }
                if (elemnt["slides"]).exists() {
    
                    var tmpImgUrlArray : [String] = []
                    if tmpImgUrlArray.count > 0 {
                    tmpImgUrlArray.removeAll()
                    }
                    for elemnt in (elemnt["slides"]).arrayValue {
                        let tmpIMGurl = (elemnt["image_url"]).description
                        tmpImgUrlArray.append(tmpIMGurl)
                    }
                    galleryImageUrlArray.append(tmpImgUrlArray)
                }
                else {
                    galleryImageUrlArray.append([])
                }
                if (elemnt["categories"]).exists() {
                    
                } else {
                    
                }
                if (elemnt["channels"]).exists() {
                    var tmpChannels :[channels] = []
                    if tmpChannels.count > 0 {
                        tmpChannels.removeAll()
                    }
                    for elemnt in (elemnt["channels"]).arrayValue {
                        let tmpIconUrl = (elemnt["icon"]).description
                        let tmpTitleEn = (elemnt["titleEn"]).description
                        let tmpTitleFa = (elemnt["title"]).description
                        let tmpId = (elemnt["id"]).description
                        let t = channels(titleEn: tmpTitleEn, titleFa: tmpTitleFa, id: tmpId, iconUrl: tmpIconUrl)
                        tmpChannels.append(t)
                    }
                    galleryChannelsDataArray.append(tmpChannels)


                } else {
                    
                }

                
            }
        }
        
        ///end
        
//        print("------")

    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sectionArrays.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sectionArrays[indexPath.section] {
        case "advertisement" :
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeOneCell", for: indexPath as IndexPath) as! SliderTypeOneCell
//            print("\(galleryScaleArray[indexPath.section])")
            cell.galleryScale = "\(galleryScaleArray[indexPath.section])"

            cell.imageUrl = galleryImageUrlArray[indexPath.section]
            
            cell.initView(scale: "1:1", loopTime: galleryLoopTimeArray[indexPath.section], imageUrlll: galleryImageUrlArray[indexPath.section])

            return cell

            break
        case "channelFeaturedCategory" :
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeTwoCell", for: indexPath as IndexPath) as! SliderTypeTwoCell
//            cell.textLabel!.text = "\(sectionArrays[indexPath.section])"

            cell.lblTitle.text = "\(sectionTitleArrays[indexPath.section])"
            cell.channelsDataArray = galleryChannelsDataArray[indexPath.section]
            cell.collectionCounts = sectionArrays.filter({$0 == "channelFeaturedCategory"}).count // 3

            cell.initView()

            return cell

            break
        case "channelNormalCategory" :
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeThreeCell", for: indexPath as IndexPath) as! SliderTypeThreeCell

            return cell

            break
        default :
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTypeOneCell", for: indexPath as IndexPath) as! SliderTypeOneCell
            cell.textLabel!.text = "\(sectionArrays[indexPath.section])"
            cell.backgroundColor = .red
            return cell
            

            break
        }
    }
    

}
