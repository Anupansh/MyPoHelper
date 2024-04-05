//
//  WorkerListView.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 10/28/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import UIKit

enum WorkerField: String {
    case FIRST_NAME             = "FIRST_NAME"
    case LAST_NAME              = "LAST_NAME"
    case CELL_NUMBER            = "CELL_NUMBER"
    case EMAIL                  = "EMAIL"
    case HOURLY_WORKER          = "HOURLY_WORKER"
    case SALARY                 = "SALARY"
    case CONTRACTOR             = "CONTRACTOR"
}

class WorkerListView: BaseDataTableView<Worker, WorkerField>, Storyboarded {
    
    override func viewDidLoad() {
        viewModel = WorkerListViewModel(delegate: self)
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.addShowRemovedButton()
        title = "WORKERS_LIST".localize
    }
    
    @objc override func handleAddItem() {
        if AppLocals.workerRole.role.canAddWorkers! {
            let createWorker = CreateWorkerView.instantiate(storyboard: .WORKER)
            createWorker.setViewMode(isEditingEnabled: true)
            createWorker.isAdd = true
            navigationController?.pushViewController(createWorker, animated: true)
        }
        else {
            CommonController.shared.showSnackBar(message: Constants.Message.ALLOW_WORKER, view: self)
        }
    }
    
    override func setDataTableFields() {
        dataTableFields = [
            .FIRST_NAME,
            .LAST_NAME,
            .CELL_NUMBER,
            .EMAIL,
            .HOURLY_WORKER,
            .SALARY,
            .CONTRACTOR
        ]
    }
    
    override func getHeader(for columnIndex: NSInteger) -> String {
        return dataTableFields[columnIndex].rawValue.localize
    }
    
    override func showItem(at indexPath: IndexPath) {
        let createWorker = CreateWorkerView.instantiate(storyboard: .WORKER)
        let worker = viewModel.getItem(at: indexPath.section)
        createWorker.isShowingWorker = true
        createWorker.createWorkerViewModel.setWorker(worker: worker)
        createWorker.setViewMode(isEditingEnabled: false)
        navigationController?.pushViewController(createWorker, animated: true)
    }
    
    override func editItem(at indexPath: IndexPath) {
        let createWorker = CreateWorkerView.instantiate(storyboard: .WORKER)
        let worker = viewModel.getItem(at: indexPath.section)
        createWorker.createWorkerViewModel.setWorker(worker: worker)
        createWorker.setViewMode(isEditingEnabled: true)
        navigationController?.pushViewController(createWorker, animated: true)
    }
}
