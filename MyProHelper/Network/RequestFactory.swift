//
//  RequestFactory.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 03/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

final class RequestFactory {
    
    enum Method:String {
        case GET
        case POST
        case PUT
        case DELETE
        case PATCH
    }
    
    static func request(method:Method,url:URL,parameters: Dictionary<String,Any>?) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        if parameters != nil {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters ?? Dictionary<String,Any>(), options: .fragmentsAllowed)
        }
        return request
    }
    
}
