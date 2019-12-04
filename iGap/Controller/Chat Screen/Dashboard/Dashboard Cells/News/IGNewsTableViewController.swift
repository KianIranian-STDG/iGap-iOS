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

class IGNewsTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    
    // MARK: - Outlets
    // MARK: - Variables
    var items = [IGStructNewsMainPage]()
    var deepLinkToken: String?
    
    // MARK: - View LifeCycle
    
    private func initTVCells() {
        //register Slider Cell
        tableView?.register(IGNewsSliderTVCell.nib, forCellReuseIdentifier: IGNewsSliderTVCell.identifier)
        //register double News Cell
        tableView?.register(IGOneNewsTVCell.nib, forCellReuseIdentifier: IGOneNewsTVCell.identifier)
        //register double News Cell
        tableView?.register(IGNewsDoubleNTVCell.nib, forCellReuseIdentifier: IGNewsDoubleNTVCell.identifier)
        //register Triple News Cell
        tableView?.register(IGTripleNewsTVCell.nib, forCellReuseIdentifier: IGTripleNewsTVCell.identifier)
        //register double Button Cell
        tableView?.register(IGDoubleButtonTVCell.nib, forCellReuseIdentifier: IGDoubleButtonTVCell.identifier)
        //register Single Button Cell
        tableView?.register(IGSingleButtonTVCell.nib, forCellReuseIdentifier: IGSingleButtonTVCell.identifier)
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initTVCells()
        initServices()
        initView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        initNavigationBar(title: "".localizedNew, rightAction: {})//set Title for Page and nav Buttons if needed
        
    }
    // MARK: - Development Funcs
    private func initView() {
        initFont()
        initAlignments()
        initColors()
        initStrings()
        customiseView()
        initNavigationBar()
    }
    func initNavigationBar() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: IGStringsManager.IgapNews.rawValue.localized)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func initServices() {
        getData()
    }
    private func getData() {
        
        IGApiNews.shared.getHomeItems { (isSuccess, items) in
            
            
            if isSuccess {
                self.items = items!
                self.tableView.reloadData()
            }
            
            
        }
        
    }
    
    private func customiseView() {
        
    }
    
    private func initFont() {
        
    }
    
    private func initStrings() {
        
    }
    
    private func initColors() {
        
    }
    
    private func initAlignments() {
        let isEnglish = SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue
        tableView.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        
    }
    
    // MARK: - Actions
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if items.count == 0 {
            self.tableView.setEmptyMessage(IGStringsManager.WaitDataFetch.rawValue.localized)
            let isEnglish = SMLangUtil.loadLanguage() == SMLangUtil.SMLanguage.English.rawValue
            self.tableView.backgroundView?.transform = isEnglish ? CGAffineTransform.identity : CGAffineTransform(scaleX: -1, y: 1)
        } else {
            self.tableView.restore()
        }
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        let item = items[indexPath.row]
        
        switch item.type {
        case .slider:
            
            let sliderCell = tableView.dequeueReusableCell(withIdentifier: "IGNewsSliderTVCell", for: indexPath as IndexPath) as! IGNewsSliderTVCell
            
            sliderCell.slides = (item.news![0].news)
            sliderCell.initView(scale: "16:12", loopTime: 2000)
            
            cell = sliderCell
        case .newsSingle:
            let singleNews = tableView.dequeueReusableCell(withIdentifier: "IGOneNewsTVCell", for: indexPath as IndexPath) as! IGOneNewsTVCell
            //pass array of news inner data
            singleNews.newsOne = (item.news![0].news)
            //title of double news section
            singleNews.lblTitle0.text = (item.news![0].category)
            //pass categoryID
            singleNews.categoryIDOne = (item.news![0].categoryId)

            //set cell data
            singleNews.setCellData()
            
            cell = singleNews
            
            
        case .newsDouble:
            let doubleNews = tableView.dequeueReusableCell(withIdentifier: "IGNewsDoubleNTVCell", for: indexPath as IndexPath) as! IGNewsDoubleNTVCell
            //pass array of news inner data
            doubleNews.newsOne = (item.news![0].news)
            doubleNews.newsTwo = (item.news![1].news)
            //pass categoryID
            doubleNews.categoryIDOne = (item.news![0].categoryId)
            doubleNews.categoryIDTwo = (item.news![1].categoryId)
            //title of double news section
            doubleNews.lblTitle0.text = (item.news![0].category)
            doubleNews.lblTitle1.text = (item.news![1].category)
            doubleNews.categoryOne = (item.news![0].category)
            doubleNews.categoryTwo = (item.news![1].category)
            
            
            //set cell data
            doubleNews.setCellData()
            
            cell = doubleNews
            
        case .newsTriple:
            let tripleNews = tableView.dequeueReusableCell(withIdentifier: "IGTripleNewsTVCell", for: indexPath as IndexPath) as! IGTripleNewsTVCell
            //pass array of news inner data
            tripleNews.newsOne = (item.news![0].news)
            tripleNews.newsTwo = (item.news![1].news)
            tripleNews.newsThree = (item.news![2].news)
            //title of double news section
            tripleNews.lblTitleOne.text = (item.news![0].category)
            tripleNews.lblTitleTwo.text = (item.news![1].category)
            tripleNews.lblTitleThree.text = (item.news![2].category)
            //pass categoryID
            tripleNews.categoryIDOne = (item.news![0].categoryId)
            tripleNews.categoryIDTwo = (item.news![1].categoryId)
            tripleNews.categoryIDThree = (item.news![2].categoryId)

            
            //set cell data
            tripleNews.setCellData()
            
            cell = tripleNews
            
        case .singleButton:
            let singleButton = tableView.dequeueReusableCell(withIdentifier: "IGSingleButtonTVCell", for: indexPath as IndexPath) as! IGSingleButtonTVCell
            //set title for buttons
            singleButton.btnOne.setTitle(item.buttons![0].title, for: .normal)
            //set color of buttons title
            singleButton.btnOne.setTitleColor(UIColor.hexStringToUIColor(hex: item.buttons![0].colorTitr!), for: .normal)
            //set BGcolor of buttons
            singleButton.btnOne.backgroundColor = UIColor.hexStringToUIColor(hex: item.buttons![0].color!)
            
            cell = singleButton
            
        case .doubleButton:
            let doubleButtons = tableView.dequeueReusableCell(withIdentifier: "IGDoubleButtonTVCell", for: indexPath as IndexPath) as! IGDoubleButtonTVCell
            //set title for buttons
            doubleButtons.btnOne.setTitle(item.buttons![0].title, for: .normal)
            doubleButtons.btnTwo.setTitle(item.buttons![1].title, for: .normal)
            //set color of buttons title
            doubleButtons.btnOne.setTitleColor(UIColor.hexStringToUIColor(hex: item.buttons![0].colorTitr!), for: .normal)
            doubleButtons.btnTwo.setTitleColor(UIColor.hexStringToUIColor(hex: item.buttons![1].colorTitr!), for: .normal)
            //set BGcolor of buttons
            doubleButtons.btnOne.backgroundColor = UIColor.hexStringToUIColor(hex: item.buttons![0].color!)
            doubleButtons.btnTwo.backgroundColor = UIColor.hexStringToUIColor(hex: item.buttons![1].color!)
            
            cell = doubleButtons
            
            
            
            
        default:
            cell = UITableViewCell()
            
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let item = items[indexPath.row]
        
        switch item.type {
        case .slider:
            return UITableView.automaticDimension
        case .doubleButton:
            return UITableView.automaticDimension
        case .singleButton:
            return UITableView.automaticDimension
        case .newsTriple:
            return UITableView.automaticDimension
        case .newsDouble:
            return (UIScreen.main.bounds.width) / 2
        case .newsSingle:
            return UITableView.automaticDimension
            
        }
    }
    
    
}
