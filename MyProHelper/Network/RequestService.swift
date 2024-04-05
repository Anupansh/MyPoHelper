//
//  RequestService.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 03/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

class RequestService {
    
    func loadData(parameters: Dictionary<String,Any>? = nil, urlString:String,session:URLSession = URLSession(configuration: .default),method: RequestFactory.Method, completion:@escaping(Result<Data,ErrorResult>) -> ()) -> URLSessionTask? {
        guard let url = URL(string: urlString) else {
            completion(.failure(.network(string: "")))
            return nil
        }
        
        var request = RequestFactory.request(method: method, url: url,parameters: parameters)
        
        if !Reachability.shared.isConnected {
            request.cachePolicy = .returnCacheDataDontLoad
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.network(string: "" + error.localizedDescription)))
                return
            }
            
            if let data = data {
                completion(.success(data))
            }
        }
        task.resume()
        return task
        
    }
    
}
