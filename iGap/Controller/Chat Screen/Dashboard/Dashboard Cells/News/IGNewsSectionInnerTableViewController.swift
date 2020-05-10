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
import SnapKit

class IGNewsSectionInnerTableViewController: BaseTableViewController {
    var categoryID : String! = "0"
    var category : String! = IGStringsManager.latestNews.rawValue.localized
    var currentPage: Int = 1
    var items = [contentsInnerNews]()
    var topItem : contentsInnerNews!
    var TopHeaderImage : UIImageView!
    var TopHeaderLabel : UILabel!
    var TopHeaderId : String! = ""
    var currentSegmentIndex = 2
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.estimatedSectionHeaderHeight = 40.0
        self.tableView.contentInsetAdjustmentBehavior = .never
        // Set a header for the table view
        tableView.tableHeaderView = makeTopHeader()
        makeHeaderContets(header: tableView!.tableHeaderView!)
        
        getData()
        initNavigationBar()
        initTheme()
    }
    private func initTheme() {
        self.tableView.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        TopHeaderLabel.textColor = ThemeManager.currentTheme.LabelColor

    }

    private func makeTopHeader() -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 300))
        header.backgroundColor = .red
        
        TopHeaderImage = UIImageView()
        
        TopHeaderImage.image = UIImage(named : "1")
        TopHeaderImage.contentMode = .scaleAspectFill
        
        
        TopHeaderLabel = UILabel()
        TopHeaderLabel.numberOfLines = 3
        TopHeaderLabel.font = UIFont.igFont(ofSize: 20,weight: .bold)
        TopHeaderLabel.textColor = .black
        TopHeaderLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        TopHeaderLabel.textAlignment = .center
        header.addSubview(TopHeaderImage)
        header.addSubview(TopHeaderLabel)

        return header
    }
    func makeHeaderContets(header : UIView) {
            TopHeaderImage.translatesAutoresizingMaskIntoConstraints = false

            TopHeaderImage.leadingAnchor.constraint(equalTo: header.leadingAnchor).isActive = true
            TopHeaderImage.trailingAnchor.constraint(equalTo: header.trailingAnchor).isActive = true
            TopHeaderImage.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
            TopHeaderImage.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true

        TopHeaderLabel.translatesAutoresizingMaskIntoConstraints = false

        TopHeaderLabel.leadingAnchor.constraint(equalTo: header.leadingAnchor).isActive = true
        TopHeaderLabel.trailingAnchor.constraint(equalTo: header.trailingAnchor).isActive = true
        TopHeaderLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        TopHeaderLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapOnTopHeader(_:)))
        header.addGestureRecognizer(tap)

    }
    @objc func handleTapOnTopHeader(_ sender: UITapGestureRecognizer? = nil) {

        print("TAPPED")
        gotToNewsPage(articleID: topItem.id!)
    }

    func initNavigationBar() {
        let navigationItem = self.navigationItem as! IGNavigationItem
        navigationItem.addNavigationViewItems(rightItemText: nil, title: category)
        navigationItem.navigationController = self.navigationController as? IGNavigationController
        let navigationController = self.navigationController as! IGNavigationController
        navigationController.interactivePopGestureRecognizer?.delegate = self
    }
    //forced to get all the Data at once an not page by page
    private func getData() {
        IGLoading.showLoadingPage(viewcontroller: self)
        IGApiNews.shared.getNewsByID(serviceId: categoryID.inEnglishNumbersNew(), page: String(currentPage) , perPage: "999999999999") { (isSuccess, response) in
            IGLoading.hideLoadingPage()
            if isSuccess {
                if (response?.content) != nil {
                    self.items = (response?.content)!
                    if self.items.count > 0 {
                        self.TopHeaderLabel.text = self.items[0].title
                        let url = URL(string: (self.items[0].image!))
                        self.TopHeaderImage.sd_setImage(with: url, placeholderImage: UIImage(named :"1"), completed: nil)
                        self.TopHeaderId = (self.items[0].id!)
                        self.topItem = self.items[0]
                        self.items.removeFirst()

                    }
                    self.tableView.reloadData()
                    self.TopHeaderLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)


                } else {
                    self.TopHeaderLabel.text = ""
                    self.TopHeaderLabel.backgroundColor = .clear
                    self.TopHeaderImage.image = UIImage(named: "1")
                    self.items.removeAll()
                    self.tableView.reloadData()

                }
                
            } else {
                return
            }
        }
    }
    private func getMostControversialData() {
        IGLoading.showLoadingPage(viewcontroller: self)
        IGApiNews.shared.getMostControversialNewsByID(serviceId: categoryID, page: String(currentPage) , perPage: "999999999999") { (isSuccess, response) in
            IGLoading.hideLoadingPage()
            if isSuccess {
                if (response?.content) != nil {
                    self.items = (response?.content)!
                    if self.items.count > 0 {
                        self.TopHeaderLabel.text = self.items[0].title
                        let url = URL(string: (self.items[0].image!))
                        self.TopHeaderImage.sd_setImage(with: url, placeholderImage: UIImage(named :"1"), completed: nil)
                        self.TopHeaderId = (self.items[0].id!)
                        self.items.removeFirst()

                    }
                    self.tableView.reloadData()
                    self.TopHeaderLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)

                } else {
                    self.TopHeaderLabel.text = ""
                    self.TopHeaderLabel.backgroundColor = .clear
                    self.TopHeaderImage.image = UIImage(named: "1")
                    self.items.removeAll()
                    self.tableView.reloadData()

                }

            } else {
                return
            }
        }
    }
    private func getMostHitData() {
        IGLoading.showLoadingPage(viewcontroller: self)
        IGApiNews.shared.getMostHitNewsByID(serviceId: categoryID, page: String(currentPage) , perPage: "999999999999") { (isSuccess, response) in
            IGLoading.hideLoadingPage()
            if isSuccess {
                if (response?.content) != nil {
                    self.items = (response?.content)!
                    if self.items.count > 0 {
                        self.TopHeaderLabel.text = self.items[0].title
                        let url = URL(string: (self.items[0].image!))
                        self.TopHeaderImage.sd_setImage(with: url, placeholderImage: UIImage(named :"1"), completed: nil)
                        self.TopHeaderId = (self.items[0].id!)
                        self.items.removeFirst()

                    }
                    self.tableView.reloadData()
                    self.TopHeaderLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)

                } else {
                    self.TopHeaderLabel.text = ""
                    self.TopHeaderLabel.backgroundColor = .clear
                    self.TopHeaderImage.image = UIImage(named: "1")
                    self.items.removeAll()
                    self.tableView.reloadData()
                }
            } else {
                return
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    //MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect.init(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: 100))

        v.backgroundColor = ThemeManager.currentTheme.TableViewBackgroundColor
        let segmentedControl = UISegmentedControl(frame: CGRect(x: 10, y: 5, width: tableView.frame.width - 20, height: 40))

        // selected option color
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme.ButtonTextColor,NSAttributedString.Key.font : UIFont.igFont(ofSize: 15)], for: .selected)

        // color of other options
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: ThemeManager.currentTheme.LabelColor,NSAttributedString.Key.font : UIFont.igFont(ofSize: 15)], for: .normal)

        segmentedControl.tintColor = ThemeManager.currentTheme.NavigationFirstColor
        segmentedControl.insertSegment(withTitle: IGStringsManager.mostErgent.rawValue.localized, at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: IGStringsManager.mostSeen.rawValue.localized, at: 1, animated: false)
        segmentedControl.insertSegment(withTitle: IGStringsManager.latestNews.rawValue.localized, at: 2, animated: false)


        segmentedControl.selectedSegmentIndex = currentSegmentIndex

        segmentedControl.backgroundColor = ThemeManager.currentTheme.TableViewCellColor.darker(by: 20)

        segmentedControl.addTarget(self, action: #selector(self.segmentedControlValueChanged(_:)), for: .valueChanged)

        
        v.addSubview(segmentedControl)
        return v
    }
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            print("SELECTED ONE")
            currentSegmentIndex = 0
            getMostControversialData()

        } else if sender.selectedSegmentIndex == 1 {
            print("SELECTED TWO")
            currentSegmentIndex = 1
            getMostHitData()


        } else if sender.selectedSegmentIndex == 2 {
            print("SELECTED THREE")
            currentSegmentIndex = 2
            getData()


        }

    }
    private func gotToNewsPage(articleID: String) {
        IGLoading.showLoadingPage(viewcontroller: self)
        IGApiNews.shared.getNewsDetail(articleId: articleID) { (isSuccess, response) in
            IGLoading.hideLoadingPage()
            if isSuccess {
                let newsDetail = IGNewsDetailTableViewController.instantiateFromAppStroryboard(appStoryboard: .News)
                newsDetail.item = response!
                UIApplication.topViewController()!.navigationController!.pushViewController(newsDetail, animated: true)

            } else {
                return
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    //MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IGNewsSectionInnerTVCell", for: indexPath as IndexPath) as! IGNewsSectionInnerTVCell
        cell.categoryID = categoryID
        let item = items[indexPath.item]
        let url = URL(string: (item.image!))
        cell.imgNews.sd_setImage(with: url, placeholderImage: UIImage(named :"1"), completed: nil)
        
        cell.lblAgency.text = item.originalSource
        cell.lblAgency.textColor = UIColor.hexStringToUIColor(hex: "b60000")
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: item.date!.checkTime())
        let tmpArray = item.date!.components(separatedBy: " ")

        let tmpDate = date!.completeHumanReadableTime(showHour: true) ?? "..."
        let array = tmpDate.components(separatedBy: " - ")
        print("||||CHECK DATE ARRAY||||||",array[0])
        print("||||CHECK DATE ARRAY2||||||",tmpArray[1])
        cell.lblDate.text = array[0].inLocalizedLanguage() + " | " + tmpArray[1].inLocalizedLanguage()
        cell.lblAlias.text = item.title
        cell.lblSeenCount.text = item.views?.inLocalizedLanguage()
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let aricleID = items[indexPath.row].id
        gotToNewsPage(articleID: aricleID!)
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = ThemeManager.currentTheme.TableViewCellColor

    }


}
