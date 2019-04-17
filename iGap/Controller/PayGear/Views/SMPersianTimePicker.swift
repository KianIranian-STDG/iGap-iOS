//
//  SMTimePickerTextField.swift
//  PayGear
//
//  Created by amir soltani on 4/17/18.
//  Copyright © 2018 Samsoon. All rights reserved.
//

import UIKit


enum SMPersianTimePickerInputs {
    case Hour
	case Minute
    case Day
    case Month
    case Year
}

protocol SMPersianTimePickerDelegate {
	func doneButtonDidSelect(selectedDateString: String, selectedDate: Date)
}

extension SMPersianTimePicker {
	
	func doneButtonDidSelect(selectedDateString: String, selectedDate: Date) {
		
	}
}
class SMPersianTimePicker: UIView , UIPickerViewDataSource, UIPickerViewDelegate {
    
    var pickerinputView : UIPickerView = UIPickerView()
	var selectedLbl : UILabel!
	
	var inputs: [SMPersianTimePickerInputs] =
		[.Year, .Month, .Day] {
		//[.Hour, .Minute, .Year, .Day, .Month] {
        didSet {
            updateModels()
            self.pickerinputView.reloadAllComponents()
        }
    }
    var showTimeLabel = true
    var showMonthLabel = false
    
    var selectedDate: Date?
	var selectedDateString: String?
	var delegate: SMPersianTimePickerDelegate!
    private var isKeyboardUp = false
    fileprivate var models = [TimePickerComponentsModel]()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.initView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.initView()
	}
	
    func initView() {
	
        pickerinputView = UIPickerView(frame:CGRect(x: 0,y: 0,width: UIScreen.main.bounds.width,height: 200))
        pickerinputView.delegate = self
        pickerinputView.dataSource = self
		self.addSubview(pickerinputView)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		
        updateModels()
        
        self.addToolBar()
    }
    
    
    func updateModels() {
        models = []
		
		for input in inputs {
			if input == .Hour {
				models.append(TimePickerHourModel())
			}
			if input == .Minute {
				models.append(TimePickerMinuteModel())
			}
			if input == .Year {
				models.append(TimePickerYearModel())
			}
			if input == .Month {
				models.append(TimePickerMonthModel())
			}
			if input == .Day {
				models.append(TimePickerDayModel())
			}
		}
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return models.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if component < pickerView.numberOfComponents {
			return models[component].rowCount
		}
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35.0
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {

//		return (self.frame.width / CGFloat( pickerView.numberOfComponents) )
//		if models[component].type == .year || models[component].type == .month {
            return 70
//        }
//        return 40.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel : UILabel
        if let label = view as? UILabel {
            pickerLabel = label
        } else {
            pickerLabel = UILabel()
            pickerLabel.font = SMFonts.IranYekanRegular(15)
            pickerLabel.textColor = .black
            pickerLabel.textAlignment = .center
        }
        
        pickerLabel.text = models[component].values[row].inLocalizedLanguage()
        if models[component].type == .year {
            pickerLabel.textAlignment = .right
        }
        
        pickerView.subviews[1].isHidden = true
        pickerView.subviews[2].isHidden = true
        
        return pickerLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.updateDateText()
    }
    
    
    @objc func pickerDidShow() {
		
            if self.selectedDate == nil {
                self.selectedDate = Date()
            }
            
            for component in 0..<pickerinputView.numberOfComponents {
                let model = models[component]
                var row = 0
                switch model.type {
                case .hour:
                    row = SMDateUtil.toHourMinute(self.selectedDate!).0 ?? 0
                case .minute:
                    row = SMDateUtil.toHourMinute(self.selectedDate!).1 ?? 0
                case .year:
					let year = SMConstants.sourceYear()
                    row = (self.selectedDate?.localizedDateByComponent().0 ?? year) - year
                case .month:
                    row = (self.selectedDate?.localizedDateByComponent().1 ?? 1) - 1
                case .day:
                    row = ((self.selectedDate?.localizedDateByComponent().2 ?? 1) - 1)
                }
                pickerinputView.selectRow(row, inComponent: component, animated: false)
            }
            self.updateDateText()
		
    }
    
    
    func updateDateText() {
        
        if self.selectedDate == nil {
            self.selectedDate = Date()
        }
        
        var day = self.selectedDate?.localizedDateByComponent().2 ?? 1
        var month = self.selectedDate?.localizedDateByComponent().1 ?? 1
        var year = self.selectedDate?.localizedDateByComponent().0 ?? SMConstants.sourceYear()
        var minute = SMDateUtil.toHourMinute(self.selectedDate!).1 ?? 0
        var hour = SMDateUtil.toHourMinute(self.selectedDate!).0 ?? 0
        
        
        var dateText = ""
        
        for component in 0..<pickerinputView.numberOfComponents {
            let model = models[component]
            let row = pickerinputView.selectedRow(inComponent: component)
            switch model.type {
            case .hour:
                hour = row
                dateText = model.values[row]
            case .minute:
                minute = row
                dateText = dateText + ":" + model.values[row]
                if showTimeLabel {
                    dateText = "ساعت " + dateText
                }
            case .year:
                year = Int(model.values[row])!
                dateText = model.values[row] + " " + dateText
            case .month:
                month = row + 1
                if showMonthLabel {
                    dateText = "ماه " + dateText
                }
                dateText = model.values[row] + " " + dateText
            case .day:
                day = row + 1
                dateText = model.values[row] + " " + dateText
            }
        }
        
        
        if let date = Date.toDate(year, month: month, day: day) {
//            let monthFromDate = SMDateUtil.toPersianYearMonthDate(date).1!
//            if monthFromDate == month {
		
                self.selectedDateString = dateText.inLocalizedLanguage()
                self.selectedDate = date
				self.selectedLbl.text = dateText.inLocalizedLanguage()
//            }
        }
		
        
    }
	
    
    func setTextForSelectedDate() {
        if self.selectedDate == nil {
            return
        }
        
        let day = self.selectedDate?.localizedDateByComponent().2 ?? 1
        let month = self.selectedDate?.localizedDateByComponent().1 ?? 1
        let year = self.selectedDate?.localizedDateByComponent().0 ?? SMConstants.sourceYear()
        let minute = SMDateUtil.toHourMinute(self.selectedDate!).1 ?? 0
        let hour = SMDateUtil.toHourMinute(self.selectedDate!).0 ?? 0
        
        var dateText = ""
        for component in 0..<pickerinputView.numberOfComponents {
            let model = models[component]
            switch model.type {
            case .hour:
                dateText = "\(hour)"
            case .minute:
                dateText = dateText + ":" + "\(minute)"
                if showTimeLabel {
                    dateText = "ساعت " + dateText
                }
            case .year:
                dateText = "\(year)" + " " + dateText
            case .month:
                if showMonthLabel {
                    dateText = "ماه " + dateText
                }
                dateText = model.values[month - 1] + " " + dateText
            case .day:
                dateText = "\(day)" + " " + dateText
            }
        }
        
        self.selectedLbl.text = dateText.inLocalizedLanguage()
        
    }
    
    
    
    
    func addToolBar(){
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let doneButton = UIBarButtonItem(title: "OK".localized, style: UIBarButtonItem.Style.done, target: self, action: #selector(donePressed))
        
        doneButton.setTitleTextAttributes([
            NSAttributedString.Key.font: SMFonts.IranYekanRegular(17),
            NSAttributedString.Key.foregroundColor: SMColor.PrimaryColor],
                                          for: .normal)
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
		
		selectedLbl = UILabel(frame: CGRect(x: 100, y: 0, width: UIScreen.main.bounds.width - 100, height: 40))
//		selectedLbl.backgroundColor = .red
		selectedLbl.textAlignment = .right
		selectedLbl.font = SMFonts.IranYekanRegular(15)
		selectedLbl.minimumScaleFactor = 0.5
		let textFieldItem = UIBarButtonItem(customView: selectedLbl)
		
		toolBar.setItems([doneButton, spaceButton, textFieldItem], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
		

		self.addSubview(toolBar)
    }
	
    @objc func donePressed() {
        self.endEditing(true)
		
		removeViewFromSuperView()
		delegate.doneButtonDidSelect(selectedDateString: selectedDateString!, selectedDate: selectedDate!)
		
    }
	

	func removeViewFromSuperView () {
		UIView.animate(withDuration: 0.3, animations: {
			var frame = self.frame
			let window = UIApplication.shared.keyWindow!
			frame.origin.y = window.bounds.height
			self.frame = frame
		}) { (bool) in
			self.removeFromSuperview()
		}
	}
}



// MARK: MVVM Of TimePicker:

enum TimePickerComponentsType {
    case hour
    case minute
    case year
    case month
    case day
}


protocol TimePickerComponentsModel {
    var type: TimePickerComponentsType { get }
    var rowCount: Int { get }
    var values: [String] { get }
}

class TimePickerHourModel: TimePickerComponentsModel {
    var type: TimePickerComponentsType {
        return .hour
    }
    
    var rowCount: Int {
        return 24
    }
    
    var values: [String] {
        var array = [String]()
        for i in 0..<24 {
            array.append("\(i)")
        }
        return array
    }
}

class TimePickerMinuteModel: TimePickerComponentsModel {
    var type: TimePickerComponentsType {
        return .minute
    }
    
    var rowCount: Int {
        return 60
    }
    
    var values: [String] {
        var array = [String]()
        for i in 0..<60 {
            if "\(i)".length == 1 {
                array.append("0\(i)")
            } else {
                array.append("\(i)")
            }
        }
        return array
    }
}

class TimePickerYearModel: TimePickerComponentsModel {
    var type: TimePickerComponentsType {
        return .year
    }
    
    var rowCount: Int {
        return values.count
    }
    
    var values: [String] {
        var array = [String]()
		let year = SMConstants.sourceYear()
        for i in year...year + 120 {
            array.append("\(i)")
        }
        return array
    }
}


class TimePickerMonthModel: TimePickerComponentsModel {
    var type: TimePickerComponentsType {
        return .month
    }
    
    var rowCount: Int {
        return 12
    }
    
    var values: [String] {
		if SMLangUtil.lang == SMLangUtil.SMLanguage.English.rawValue {
			return SMDateUtil.months_eng
		}
        return  SMDateUtil.months
    }
}


class TimePickerDayModel: TimePickerComponentsModel {
    var type: TimePickerComponentsType {
        return .day
    }
    
    var rowCount: Int {
        return 31
    }
    
    var values: [String] {
        var array = [String]()
        for i in 1...31 {
            array.append("\(i)")
        }
        return array
    }
}

