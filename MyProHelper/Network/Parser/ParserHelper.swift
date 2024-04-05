//
//  ParserHelper.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 03/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

protocol Parceable {
    static func parseObjectArray(data:Data) -> Result<[Self],ErrorResult>
    static func parseObject(data:Data) -> Result<Self,ErrorResult>
}

final class ParserHelper {
    
    static func parseArray<T:Parceable>(data:Data,completion:(Result<[T],ErrorResult>) -> ()) {
        switch T.parseObjectArray(data: data) {
        case .success(let modelArray):
            completion(.success(modelArray))
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    static func parse<T:Parceable>(data:Data,completion:(Result<T,ErrorResult>) -> ()) {
        switch T.parseObject(data: data) {
        case .success(let newModel):
            completion(.success(newModel))
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
}
