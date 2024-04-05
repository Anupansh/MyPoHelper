//
//  CalenderTableViewCell.swift
//  MyProHelper
//
//  Created by Anupansh on 26/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import CalendarKit
//import DateToolsSwift

class CalenderTableViewCell: UITableViewCell, EventDataSource, DayViewDelegate {
    
    @IBOutlet weak var calenderView: UIView!
    @IBOutlet weak var changeDateTf: UITextField!
    @IBOutlet weak var dayViewBtn: UIButton!
    @IBOutlet weak var davyViewImage: UIImageView!
    
    
    public lazy var dayView: DayView = DayView()
    var jobList = [Job]()
    var datePicker = UIDatePicker()
    var vc: UIViewController?
    var isDayViewEnabled = true
    
    func dayViewDidSelectEventView(_ eventView: EventView) {
        print(eventView)
    }
    
    func dayViewDidLongPressEventView(_ eventView: EventView) {
        print(eventView)
    }
    
    func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        print(dayView)
    }
    
    func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        print(dayView)
    }
    
    func dayViewDidBeginDragging(dayView: DayView) {
        print(dayView)
    }
    
    func dayView(dayView: DayView, willMoveTo date: Date) {
        print(dayView)
    }
    
    func dayView(dayView: DayView, didMoveTo date: Date) {
        print(dayView)
    }
    
    func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        print(dayView)
    }
    func dayViewDidTransitionCancel(dayView: DayView) {
        print(dayView)
    }
    
    @objc func donePressed() {
        dayView.state?.move(to: datePicker.date)
        dayView.backgroundColor = .blue
        changeDateTf.text = DateManager.standardDateToStringWithoutHours(date: datePicker.date)
        endEditing(true)
    }
    
    func eventsForDate(_ date: Date) -> [EventDescriptor] {
        var events = [Event]()
        let startDateTime = getCompanyStartDate(date: date)
        let endDateTime = getCompanyEndDate(date: date)
        let filteredJobList = jobList.sorted(by: {$0.startDateTime! < $1.startDateTime!})  // Sorting Job according to Start Time
        let currentDate = DateManager.standardDateToStringWithoutHours(date: date)
        for job in filteredJobList {
            let scheduledDate = DateManager.standardDateToStringWithoutHours(date: job.startDateTime) // Getting Date for job
            if scheduledDate == currentDate {                                               // Comparing with Calendar Date
                let event = Event()
                
                // Preparing Info Array
                var infoArray = [String]()
                infoArray.append(job.jobContactPersonName ?? "")
                infoArray.append(job.jobContactPhone ?? "")
                infoArray.append(job.jobShortDescription ?? "")
                infoArray.append("\(DateManager.timeToString(date:job.startDateTime!))-\(DateManager.timeToString(date:job.endDateTime ?? event.startDate.addingTimeInterval(60)))")
                event.text = infoArray.reduce("", {$0 + $1 + "\n"})
                
                // Setting Background Color
                let bgColor = job.worker?.backgroundColor ?? "DCF0EF"
                if bgColor[0...0] == "#" {
                    let hexValue = bgColor[0...6]
                    event.backgroundColor = UIColor(hexString: hexValue)
                }
                else {
                    let hexValue = bgColor[0...5]
                    event.backgroundColor = UIColor(hexString: hexValue)
                }
                
                // Setting Text Color
                let fontColor = job.worker?.fontColor ?? "#000000"
                if fontColor[0...0] == "#" {
                    let hexValue = fontColor[0...6]
                    event.textColor = UIColor(hexString: hexValue)
                }
                else {
                    let hexValue = fontColor[0...5]
                    event.textColor = UIColor(hexString: hexValue)
                }
                
                // Checking DayView and NightView
                if job.startDateTime! < job.endDateTime! {
                    if isDayViewEnabled {
                        if startDateTime <= job.startDateTime! && job.endDateTime! <= endDateTime {
                            event.startDate = job.startDateTime!
                            event.endDate = job.endDateTime!
                            events.append(event)
                        }
                        else if startDateTime >= job.startDateTime! && job.endDateTime! <= endDateTime && startDateTime <= job.endDateTime! {
                            event.startDate = startDateTime
                            event.endDate = job.endDateTime!
                            events.append(event)
                        }
                        else if startDateTime <= job.startDateTime! && job.endDateTime! >= endDateTime && job.startDateTime! <= endDateTime {
                            event.startDate = job.startDateTime!
                            event.endDate = endDateTime
                            events.append(event)
                        }
                        else if startDateTime >= job.startDateTime! && job.endDateTime! >= endDateTime {
                            event.startDate = startDateTime
                            event.endDate = endDateTime
                            events.append(event)
                        }
                    }
                    else {
                        event.startDate = job.startDateTime!
                        event.endDate = job.endDateTime!
                        events.append(event)
                    }
                }
            }
        }
        return events
    }
    
    func getCompanyStartDate(date: Date) -> Date {
        let companySettings = DBHelper.getCompanyInformation()
        let workDateStartTime = companySettings.workDayStartTime
        let arr = workDateStartTime.components(separatedBy: ":")
        let hour = arr[0]
        let minute = arr[1]
        let second = 00
        let year = date.year
        let month = date.month
        let day = date.day
        let dateString = "\(year)-\(month)-\(day) \(hour):\(minute):\(second)"
        let newDate = DateManager.stringToDate(string: dateString)
        return newDate ?? Date()
    }
    
    func getCompanyEndDate(date: Date) -> Date {
        let companySettings = DBHelper.getCompanyInformation()
        let workDateStartTime = companySettings.workDateEndTime
        let arr = workDateStartTime.components(separatedBy: ":")
        let hour = arr[0]
        let minute = arr[1]
        let second = 00
        let year = date.year
        let month = date.month
        let day = date.day
        let dateString = "\(year)-\(month)-\(day) \(hour):\(minute):\(second)"
        let newDate = DateManager.stringToDate(string: dateString)
        return newDate ?? Date()
    }
    
    func setupDatePicker() {
        let screenWidth = UIScreen.main.bounds.width
        datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 200))
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        changeDateTf.inputView = datePicker
        let toolbar = UIToolbar(frame: CGRect(x: 200, y: 0, width: screenWidth, height: 44))
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        toolbar.setItems([cancelButton,spaceButton,doneBtn], animated: true)
        changeDateTf.inputAccessoryView = toolbar
    }
    
    @objc func cancelPressed() {
        endEditing(true)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        dayView.delegate = self
        dayView.dataSource = self
        dayView.frame = self.contentView.frame
        self.contentView.addSubview(dayView)
        dayView.translatesAutoresizingMaskIntoConstraints = false
        dayView.leadingAnchor.constraint(equalTo: self.calenderView.leadingAnchor, constant: 0).isActive = true
        dayView.trailingAnchor.constraint(equalTo: self.calenderView.trailingAnchor, constant: 0).isActive = true
        dayView.topAnchor.constraint(equalTo: self.calenderView.topAnchor, constant: 0).isActive = true
        dayView.bottomAnchor.constraint(equalTo: self.calenderView.bottomAnchor, constant: 0).isActive = true
        setupDatePicker()
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func dayViewBtnPressed(_ sender: Any) {
        if isDayViewEnabled {
            davyViewImage.image = #imageLiteral(resourceName: "night")
            dayViewBtn.setTitle("View Day Mode", for: .normal)
            dayViewBtn.backgroundColor = .systemYellow
            isDayViewEnabled = false
        }
        else {
            davyViewImage.image = #imageLiteral(resourceName: "day")
            dayViewBtn.setTitle("View Night Mode", for: .normal)
            dayViewBtn.backgroundColor = .black
            isDayViewEnabled = true
        }
        dayView.reloadData()
    }
    
    
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

class Time: Comparable, Equatable {
init(_ date: Date) {
    //get the current calender
    let calendar = Calendar.current

    //get just the minute and the hour of the day passed to it
    let dateComponents = calendar.dateComponents([.hour, .minute], from: date)

        //calculate the seconds since the beggining of the day for comparisions
        let dateSeconds = dateComponents.hour! * 3600 + dateComponents.minute! * 60

        //set the varibles
        secondsSinceBeginningOfDay = dateSeconds
        hour = dateComponents.hour!
        minute = dateComponents.minute!
    }

    init(_ hour: Int, _ minute: Int) {
        //calculate the seconds since the beggining of the day for comparisions
        let dateSeconds = hour * 3600 + minute * 60

        //set the varibles
        secondsSinceBeginningOfDay = dateSeconds
        self.hour = hour
        self.minute = minute
    }

    var hour : Int
    var minute: Int

    var date: Date {
        //get the current calender
        let calendar = Calendar.current

        //create a new date components.
        var dateComponents = DateComponents()

        dateComponents.hour = hour
        dateComponents.minute = minute

        return calendar.date(byAdding: dateComponents, to: Date())!
    }

    /// the number or seconds since the beggining of the day, this is used for comparisions
    private let secondsSinceBeginningOfDay: Int

    //comparisions so you can compare times
    static func == (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay == rhs.secondsSinceBeginningOfDay
    }

    static func < (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay < rhs.secondsSinceBeginningOfDay
    }

    static func <= (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay <= rhs.secondsSinceBeginningOfDay
    }


    static func >= (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay >= rhs.secondsSinceBeginningOfDay
    }


    static func > (lhs: Time, rhs: Time) -> Bool {
        return lhs.secondsSinceBeginningOfDay > rhs.secondsSinceBeginningOfDay
    }
}

extension Date {
    var time: Time {
        return Time(self)
    }
}
