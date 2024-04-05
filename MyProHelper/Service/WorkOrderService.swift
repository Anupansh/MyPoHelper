//
//  WorkOrderService.swift
//  MyProHelper
//
//  Created by sismac010 on 06/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import Foundation

protocol WorkOrderServiceProtocol:AnyObject {
    
    func fetchWorkOrders(showRemoved: Bool, key: String?, offset: Int, completion:@escaping((Result<[WorkOrder],ErrorResult>) -> Void))
    func fetchWorkOrders(showRemoved: Bool, key: String?, sortBy: WorkOrderField?,sortType: SortType? ,offset: Int, completion:@escaping((Result<[WorkOrder],ErrorResult>) -> Void))
    func createWorkOrder(workOrder: WorkOrder, completion:@escaping((Result<Int64,ErrorResult>) -> Void))
    func updateWorkOrder(workOrder: WorkOrder, completion:@escaping((Result<WorkOrder,ErrorResult>) -> Void))
    func deleteWorkOrder(workOrder: WorkOrder, _ completion:@escaping((Result<String,ErrorResult>) -> Void))
    func undeleteWorkOrder(workOrder: WorkOrder, _ completion:@escaping((Result<String,ErrorResult>) -> Void))
    
}

final class WorkOrderService:RequestHandler, WorkOrderServiceProtocol{
    
    var dbService = WorkOrderRepository()
    
    func editWorkOrder(workOrder: WorkOrder, completion: @escaping ((Result<WorkOrder, ErrorResult>) -> Void)) {
        dbService.Edit(workOrder: workOrder, success: {
            completion(.success(workOrder))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchWorkOrders(showRemoved: Bool, key: String?, offset: Int, completion:@escaping((Result<[WorkOrder],ErrorResult>) -> Void)) {
        dbService.fetchWorkOrders(showRemoved: showRemoved, with: key, offset: offset) { (workOrders) in
            completion(.success(workOrders))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func fetchWorkOrders(showRemoved: Bool = false,
                       key: String?,
                       sortBy: WorkOrderField?,
                       sortType: SortType? ,
                       offset: Int,
                       completion:@escaping((Result<[WorkOrder],ErrorResult>) -> Void)) {
        dbService.fetchWorkOrders(showRemoved: showRemoved, with: key, sortBy: sortBy, sortType: sortType, offset: offset) { (workOrders) in
            completion(.success(workOrders))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }

    func createWorkOrder(workOrder: WorkOrder, completion: @escaping ((Result<Int64, ErrorResult>) -> Void)) {
        dbService.insertWorkOrder(workOrder: workOrder, success: { workOrderID in
            completion(.success(workOrderID))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func updateWorkOrder(workOrder: WorkOrder, completion: @escaping ((Result<WorkOrder, ErrorResult>) -> Void)) {
        dbService.update(workOrder: workOrder, success: {
            completion(.success(workOrder))
        }) { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func deleteWorkOrder(workOrder: WorkOrder, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.removeWorkOrder(workOrder: workOrder)  {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
    
    func undeleteWorkOrder(workOrder: WorkOrder, _ completion:@escaping((Result<String,ErrorResult>) -> Void)) {
        dbService.unremoveWorkOrder(workOrder: workOrder) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }

    
}
