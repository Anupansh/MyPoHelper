//
//  ScheduleJobViewModel.swift
//  MyProHelper
//
//  Created by Samir on 12/22/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class ScheduleJobViewModel {
    
    private var workers         : [Worker] = []
    private var jobs            : [Int:[Job]] = [:]
    private var hasMoreWorkers  : Bool = true
    private var selectedDate    : Date = Date() {
        didSet {
            jobs = [:]
        }
    }

    var scheduleJobModel = Box(ScheduleJobModel())
    
    func calculateEndTime() {
        guard let startTime = scheduleJobModel.value.startTime else { return }
        guard let duration  = scheduleJobModel.value.duration else { return }
        guard let frameDate = DateManager.timeFrameStringToDate(time: duration) else { return }
        
        let calendar    = Calendar.current
        let hours       = frameDate.hour
        let minutes     = frameDate.minute
        
        if let hourDate = calendar.date(byAdding: .hour, value: hours, to: startTime), let endDate = calendar.date(byAdding: .minute, value: minutes, to: hourDate) {
            scheduleJobModel.value.endTime = endDate
        }
    }

    func countWorkers() -> Int {
        return workers.count
    }

    func getWorker(at index: Int) -> String {
        return workers[index].fullName ?? ""
    }
    
    func getJobs(at index: Int) -> [Job] {
        let worker = workers[index]
        if let workerId = worker.workerID,
           let workerJobs = jobs[workerId] {
            return workerJobs
        }
        return []
    }

    func getJobForWorker(at index: Int, with time: String) -> Job? {
        guard let workerId = workers[index].workerID else { return nil }
        guard let jobsForWorker = jobs[workerId] else { return nil }
        let jobWithTime = jobsForWorker.first(where: { job in
            let startTime = getJobTime(date: job.startDateTime)
            let endTime = getJobTime(date: job.endDateTime)
            return startTime == time || endTime == time
        })
        return jobWithTime
    }

    func getJobTime(date: Date?) -> String {
        guard let date = date else { return ""}
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    func getWorkerColor(at index: Int) -> String {
        return workers[index].backgroundColor ?? ""
    }

    func getWorkerTextColor(at index: Int) -> String {
        return workers[index].fontColor ?? ""
    }

    func getScheduledJob() -> ScheduleJobModel {
        return scheduleJobModel.value
    }

    func getNextDate() -> Date? {
        let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)
        return nextDate
    }

    func getPreviousDate() -> Date? {
        let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)
        return previousDate
    }

    func setDate(date: Date) {
        selectedDate = date
    }

    func setWorker(at index: Int) {
        scheduleJobModel.value.worker = workers[index]
    }
    
    func setStartTime(time: String) {
        guard let time = formatTime(time: time) else { return }
        let dayString = DateManager.standardDateToStringWithoutHours(date: selectedDate)
        let dateString = dayString + " " + time
        if let date = DateManager.stringToDate(string: dateString) {
            scheduleJobModel.value.startTime = date
        }
    }

    private func formatTime(time: String) -> String? {
        let timeFormatter = DateFormatter()
        let standardTimeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        standardTimeFormatter.dateFormat = "HH:mm:ss"
        if let date = timeFormatter.date(from: time) {
            return standardTimeFormatter.string(from: date)
        }
        else {
            return nil
        }
    }
    
    func setTimeDuration(duration: String) {
        scheduleJobModel.value.duration = duration
        calculateEndTime()
    }
    
    func fetchWorkers(completion: @escaping ()->()) {
        guard hasMoreWorkers else { return }
        let workerService = WorkersService()

        workerService.fetchWorkers(offset: 0) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let workers):
                self.hasMoreWorkers = workers.count == Constants.DATA_OFFSET
                self.workers = workers
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }

    func fetchMoreWorkers(completion: @escaping ()->()) {
        guard hasMoreWorkers else { return }
        let offset = workers.count
        let workerService = WorkersService()

        workerService.fetchWorkers(offset: offset) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let workers):
                self.hasMoreWorkers = workers.count == Constants.DATA_OFFSET
                self.workers.append(contentsOf: workers)
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchAllWorkersJobs(completion: @escaping () -> ()) {
        let jobsWorkerService = JobsWorkersService()
        let workersId = workers.compactMap({ $0.workerID })
        let dateString = DateManager.standardDateToStringWithoutHours(date: selectedDate)
        jobsWorkerService.fetchJobsWorker(for: workersId,date: dateString) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let jobsWorkers):
                jobsWorkers.forEach { (jobsWorker) in
                    self.updateJobs(jobsWorker: jobsWorker)
                }
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }

    private func updateJobs(jobsWorker: JobsWorkers) {
        if let workerId = jobsWorker.workerId {
            if self.jobs[workerId] != nil {
                if let job = jobsWorker.job,
                   !self.isJobExists(for: workerId, job: job) {
                    self.jobs[workerId]?.append(job)
                }
            }
            else {
                if let job = jobsWorker.job {
                    self.jobs.updateValue([job], forKey: workerId)
                }
            }

        }
    }

    private func isJobExists(for workerId: Int, job: Job) -> Bool {
        let hasJob = jobs[workerId]?.contains(where: {
            return $0.jobID == job.jobID
        })
        return hasJob ?? false
    }
}
