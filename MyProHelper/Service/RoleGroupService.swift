//
//  WorkerRolesGroupService.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 30/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

final class RoleGroupService {
    
    private let repository = RoleGroupRepository()
    
    func fetchRolesGroup(showRemoved: Bool,key: String? = nil, showSelect: Bool = false, offset: Int,_ completion: @escaping (_ result: (Result<[WorkerRolesGroup], Error>)) -> ()) {
        repository.fetchRolesGroup(showRemoved: showRemoved,key: key, showSelect: showSelect, offset: offset) { (groups) in
            completion(.success(groups))
        }
        failure: { (error) in
            completion(.failure(error))
        }
    }
    
    
//    func fetchRolesGroup(showSelect: Bool = true, offset: Int, completion: @escaping (_ result: (Result<[WorkerRolesGroup], Error>)) -> ()) {
//        repository.fetchRolesGroup(showSelect: showSelect, offset: offset) { (groups) in
//            completion(.success(groups))
//        } failure: { (error) in
//            completion(.failure(error))
//        }
//    }
    
    func createRolesGroup(group: WorkerRolesGroup,completion: @escaping (_ result: (Result<Int64, Error>)) -> ()) {
        repository.insertRolesGroup(rolesGroup: group) { (groupID) in
            completion(.success(groupID))
        } failure: { (error) in
            completion(.failure(error))
        }
    }
    
    func updateRolesGroup(group: WorkerRolesGroup,completion: @escaping (_ result: (Result<String,Error>)) -> ()) {
        repository.update(rolesGroup: group) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(error))
        }
    }
    
    func deleteRoleGroup(group: WorkerRolesGroup,completion: @escaping (_ result: (Result<String,Error>)) -> ()) {
        repository.deleteWorkerRole(group: group) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(error))
        }
    }
    
    func restoreRoleGroup(group: WorkerRolesGroup, completion: @escaping ((Result<String, ErrorResult>) -> Void)) {
        repository.restoreWorkerRole(group: group) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }

}
