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

class IGSettingChatFontSizeTableViewController: UITableViewController {
    
    @IBOutlet weak var deviceSettingSwitcher: UISwitch!
    @IBOutlet weak var mediumFontSizeCell: UITableViewCell!
    let greenColor = UIColor.organizationalColor()
    var currentSelectedCellIndexPath : IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        setBarbuttonItem()
        setDefualtFontSize()
        self.tableView.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
        deviceSettingSwitcher.addTarget(self, action: #selector(IGSettingChatFontSizeTableViewController.stateChanged), for: UIControl.Event.valueChanged)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfSection = 0
        if deviceSettingSwitcher.isOn{
            numberOfSection = 1
        }else{
            numberOfSection = 2
        }
        return numberOfSection
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows : Int = 0
        switch section {
        case 0:
            numberOfRows = 1
        case 1 :
            numberOfRows = 4
        default:
            break
        }
        return numberOfRows
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0 {
            if let currentCell = tableView.cellForRow(at: indexPath){
                currentCell.selectedBackgroundView?.backgroundColor = UIColor.clear
                if currentCell != mediumFontSizeCell {
                    mediumFontSizeCell.accessoryType = .none
                }
                if (currentCell.accessoryType == UITableViewCell.AccessoryType.none) {
                    currentCell.accessoryType = UITableViewCell.AccessoryType.checkmark
                }else{
                    (currentCell.accessoryType = UITableViewCell.AccessoryType.none)
                }
            }
        }
        currentSelectedCellIndexPath  = indexPath
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let currentCell = tableView.cellForRow(at: indexPath)
        if let selectedCell = currentCell {
            if selectedCell.accessoryType == UITableViewCell.AccessoryType.checkmark {
                selectedCell.accessoryType = UITableViewCell.AccessoryType.none
            }
        }
    }
    @objc func stateChanged(){
        if deviceSettingSwitcher.isOn {
            if let lastSelectedIndexPath = currentSelectedCellIndexPath {
                tableView.deselectRow(at: lastSelectedIndexPath, animated: true)
                let cell = tableView.cellForRow(at: lastSelectedIndexPath)
                cell?.accessoryType = .none
            }
            self.tableView.reloadData()
        }else{
            setDefualtFontSize()
            self.tableView.reloadData()
        }
    }
    func setDefualtFontSize(){
        mediumFontSizeCell.accessoryType = .checkmark
    }
    func setBarbuttonItem(){
        //nextButton
        let doneBtn = UIButton()
        doneBtn.frame = CGRect(x: 8, y: 300, width: 60, height: 0)
        let normalTitleFont = UIFont.systemFont(ofSize: UIFont.buttonFontSize, weight: UIFont.Weight.semibold)
        let normalTitleColor = greenColor
        let attrs = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): normalTitleFont, convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): normalTitleColor]
        let doneTitle = NSAttributedString(string: "Done", attributes: convertToOptionalNSAttributedStringKeyDictionary(attrs))
        doneBtn.setAttributedTitle(doneTitle, for: .normal)
        doneBtn.addTarget(self, action: #selector(IGSettingChatFontSizeTableViewController.doneButtonClicked), for: UIControl.Event.touchUpInside)
        let topRightBarbuttonItem = UIBarButtonItem(customView: doneBtn)
        self.navigationItem.rightBarButtonItem = topRightBarbuttonItem
    }
    @objc func doneButtonClicked(){
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
