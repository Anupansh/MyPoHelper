//
//  ScheduleJobView.swift
//  MyProHelper
//
//  Created by Samir on 12/22/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit
import SpreadsheetView
import SideMenu

class ScheduleJobView: BaseViewController, Storyboarded {

    @IBOutlet weak private var scheduleJobSpreadSheet   : SpreadsheetView!
    @IBOutlet weak private var dateLabel                : UILabel!
    @IBOutlet weak private var dateTextfieldView        : UIView!
    @IBOutlet weak var nightModeBtn: UIButton!
    var nightModeEnabled = false
    
    private var dateView        : DateView!
    private var workersList     : AppListView!

    let scheduleJobViewModel = ScheduleJobViewModel()

    private var hours = ["8:00 AM",
                         "8:30 AM",
                         "9:00 AM",
                         "9:30 AM",
                         "10:00 AM",
                         "10:30 AM",
                         "11:00 AM",
                         "11:30 AM",
                         "12:00 AM",
                         "12:30 AM",
                         "1:00 PM",
                         "1:30 PM",
                         "2:00 PM",
                         "2:30 PM",
                         "3:00 PM",
                         "3:30 PM",
                         "4:00 PM",
                         "4:30 PM",
                         "5:00 PM",
                         "5:30 PM"]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDatePicker()
        setupWorkersView()
        setupSpreadSheet()
        setupTextTextfieldView()
        setupDateLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchWorkers()
    }

    private func setupSpreadSheet() {
        scheduleJobSpreadSheet.dataSource   = self
        scheduleJobSpreadSheet.delegate     = self
        scheduleJobSpreadSheet.bounces      = false

        scheduleJobSpreadSheet.register(WorkerSpreatSheetCell.self,
                                        forCellWithReuseIdentifier: WorkerSpreatSheetCell.ID)
        scheduleJobSpreadSheet.register(TimeSpreadSheetCell.self,
                                        forCellWithReuseIdentifier: TimeSpreadSheetCell.ID)
        scheduleJobSpreadSheet.register(JobSpreadSheetCell.self,
                                        forCellWithReuseIdentifier: JobSpreadSheetCell.ID)
        scheduleJobSpreadSheet.register(EmptySpreadSheetCell.self,
                                        forCellWithReuseIdentifier: EmptySpreadSheetCell.ID)
    }

    private func setupTextTextfieldView() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(handleChangeDate))
        dateTextfieldView.isUserInteractionEnabled = true
        dateTextfieldView.addGestureRecognizer(tapGesture)
        dateTextfieldView.backgroundColor = Constants.Colors.DARK_NAVIGATION
    }

    private func setupDateLabel() {
        let dateString = DateManager.dateToString(date: Date())
        dateLabel.text = dateString
    }

    private func setupDatePicker() {
        dateView = DateView.instantiate(storyboard: .HOME)
        dateView.delegate = self
    }
    
    private func setupWorkersView() {
        workersList = AppListView.instantiate(storyboard: .HOME)
    }
    
    @objc private func handleChangeDate() {
        present(dateView, animated: true)
    }
    
    private func openPickTimeView() {
        let pickTimeView = PickTimeView.instantiate(storyboard: .HOME)
        pickTimeView.timeFrame.bind { [weak self] (time) in
            guard let self = self, let time = time else { return }
            self.scheduleJobViewModel.setTimeDuration(duration: time)
            self.navigationController?.popViewController(animated: true)
        }
        present(pickTimeView, animated: true, completion: nil)
    }
    
    private func fetchWorkers() {
        scheduleJobViewModel.fetchWorkers {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.scheduleJobSpreadSheet.reloadData()
                self.fetchAllWorkersJobs()
            }
        }
    }

    private func fetchMoreWorkers() {
        scheduleJobViewModel.fetchMoreWorkers {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.scheduleJobSpreadSheet.reloadData()
                self.fetchAllWorkersJobs()
            }
        }
    }
    
    private func fetchAllWorkersJobs() {
        scheduleJobViewModel.fetchAllWorkersJobs {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.scheduleJobSpreadSheet.reloadData()
            }
        }
    }

    @IBAction private func nextDatePressed(sender: UIButton) {
        guard let nextDate = scheduleJobViewModel.getNextDate() else { return }
        let dateString = DateManager.dateToString(date: nextDate)
        scheduleJobViewModel.setDate(date: nextDate)
        fetchAllWorkersJobs()
        dateLabel.text = dateString
    }

    @IBAction private func previousDatePressed(sender: UIButton) {
        guard let previousDate = scheduleJobViewModel.getPreviousDate() else { return }
        let dateString = DateManager.dateToString(date: previousDate)
        scheduleJobViewModel.setDate(date: previousDate)
        fetchAllWorkersJobs()
        dateLabel.text = dateString
    }
    
    @IBAction func nightModeBtnPressed(_ sender: Any) {
        if nightModeEnabled {
            nightModeBtn.setTitle("Night Mode", for: .normal)
            nightModeEnabled = false
        }
        else {
            nightModeBtn.setTitle("Day Mode", for: .normal)
            nightModeEnabled = true
        }
        updateHours()
    }
    
    func updateHours() {
        if nightModeEnabled {
            hours = ["12:00 AM","12:30 AM","1:00 AM","1:30 AM","2:00 AM","2:30 AM","3:00 AM","3:30 AM","4:00 AM","4:30 AM","5:00 AM","5:30 AM","6:00 AM","6:30 AM","7:00 AM","7:30 AM","8:00 AM","8:30 AM","9:00 AM","9:30 AM","10:00 AM","10:30 AM","11:00 AM","11:30 AM","12:00 PM","12:30 PM","1:00 PM","1:30 PM","2:00 PM","2:30 PM","3:00 PM","3:30 PM","4:00 PM","4:30 PM","5:00 PM","5:30 PM","6:00 PM","6:30 PM","7:00 PM","7:30 PM","8:00 PM","8:30 PM","9:00 PM","9:30 PM","10:00 PM","10:30 PM","11:00 PM","11:30 PM"]
        }
        else {
            hours = ["8:00 AM","8:30 AM","9:00 AM","9:30 AM","10:00 AM","10:30 AM","11:00 AM","11:30 AM","12:00 PM","12:30 PM","1:00 PM","1:30 PM","2:00 PM","2:30 PM","3:00 PM","3:30 PM","4:00 PM","4:30 PM","5:00 PM","5:30 PM"]
        }
        scheduleJobSpreadSheet.reloadData()
    }
    
}

// MARK: - Confomring to SpreadSheet Delegate
extension ScheduleJobView: SpreadsheetViewDelegate {
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.column == 0 {
            return
        }
        else {
            let job = scheduleJobViewModel.getJobForWorker(at: indexPath.row,with: hours[(indexPath.column - 1)])
            if job != nil {
                return
            }
            scheduleJobViewModel.setWorker(at: indexPath.row)
            scheduleJobViewModel.setStartTime(time: hours[indexPath.column - 1])
            openPickTimeView()
        }
    }
}

// MARK: - Confomring to SpreadSheet Data Source
extension ScheduleJobView: SpreadsheetViewDataSource {

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 0 {
            return 200
        }
        return 80
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 100
    }


    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return (hours.count) + 1
    }

    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return scheduleJobViewModel.countWorkers()
    }

    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }

    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }

    func mergedCells(in spreadsheetView: SpreadsheetView) -> [CellRange] {
        let odds = Array(1..<hours.count).filter { (number) in number % 2 != 0 }
        let mergedTimeCell: [CellRange] = odds.compactMap({ CellRange(from: (row: 0, column: $0),
                                                                      to: (row: 0, column: $0 + 1))})
        let mergeCell = mergedTimeCell + getMergedJobCells()
        return mergeCell
    }

    private func getMergedJobCells() -> [CellRange] {
        var mergedTimeCell: [CellRange] = []
        for workerIndex in 0..<scheduleJobViewModel.countWorkers() {
            let jobs = scheduleJobViewModel.getJobs(at: workerIndex)
            for job in jobs {
                if let startIndex = getTimeIndex(time: job.startDateTime),
                   let endIndex = getTimeIndex(time: job.endDateTime) {
                    mergedTimeCell.append(.init(from: (row: workerIndex, column: startIndex + 1),
                                                to: (row: workerIndex, column: endIndex + 1)))
                }
            }
        }
        return mergedTimeCell
    }

    func getTimeIndex(time: Date?) -> Int? {
        let time = scheduleJobViewModel.getJobTime(date: time)
        return hours.firstIndex(of: time)
    }

    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {

        if indexPath.column == 0 && indexPath.row == 0 {
            return instantiateEmptyCell(spreadsheetView, cellForItemAt: indexPath)
        }

        if indexPath.column == 0 { // worker column
            return instantiateWorkerCell(spreadsheetView, cellForItemAt: indexPath)
        }

        if indexPath.row == 0 { // time column
            return instantiateTimeCell(spreadsheetView, cellForItemAt: indexPath)
        }

        return instantiateJobCell(spreadsheetView, cellForItemAt: indexPath)
    }

    private func instantiateEmptyCell(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        guard let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: EmptySpreadSheetCell.self), for: indexPath) as? EmptySpreadSheetCell else {
            return nil
        }
        return cell
    }

    private func instantiateTimeCell(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        guard let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TimeSpreadSheetCell.self), for: indexPath) as? TimeSpreadSheetCell else {
            return nil
        }
        let time = hours[(indexPath.column - 1)]
        cell.setTime(time: time)
        return cell
    }

    private func instantiateWorkerCell(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {

        guard let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: WorkerSpreatSheetCell.self), for: indexPath) as? WorkerSpreatSheetCell else {
            return nil
        }
        let workerName = scheduleJobViewModel.getWorker(at: indexPath.row)
        cell.setWorkerName(name: workerName)

        if isLastCell(with: indexPath) {
            fetchMoreWorkers()
        }

        return cell
    }

    private func instantiateJobCell(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        guard let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: JobSpreadSheetCell.self), for: indexPath) as? JobSpreadSheetCell else {
            return nil
        }
        let job = scheduleJobViewModel.getJobForWorker(at: indexPath.row,
                                                       with: hours[(indexPath.column - 1)])
        let backgroundColor = scheduleJobViewModel.getWorkerColor(at: indexPath.row)
        let textColor = scheduleJobViewModel.getWorkerTextColor(at: indexPath.row)
        cell.bindCell(text: job?.jobShortDescription,
                      cellColor: backgroundColor,
                      textColor: textColor)
        return cell
    }

    private func isLastCell(with indexPath: IndexPath) -> Bool {
        let numberOfWorker = scheduleJobViewModel.countWorkers()
        return (numberOfWorker - 1) == indexPath.row
    }
}

// MARK: - Confomring to DateView Delegate
extension ScheduleJobView: DateViewDelegate {
    
    func dateView(controller: DateView, didSelect date: Date?) {
        guard let date = date else { return }
        let dateString = DateManager.dateToString(date: date)
        scheduleJobViewModel.setDate(date: date)
        fetchAllWorkersJobs()
        dateLabel.text = dateString
    }
}
