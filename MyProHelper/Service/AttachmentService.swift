//
//  AttachmentService.swift
//  MyProHelper
//
//  Created by Samir on 11/5/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

protocol AttachmentServiceProtocol {
    func fetchAttachment(offset: Int, completion: @escaping (_ result: Result<[Attachment], ErrorResult>)->())
    func fetchAttachment(with id: Int, source: AttachmentSource, completion: @escaping (_ result: Result<[Attachment], ErrorResult>)->())
    func addAttachment(attachment: Attachment, completion: @escaping (_ result :Result<String, ErrorResult>) -> ())
    func deleteAttachment(attachment: Attachment, completion: @escaping (_ result :Result<String, ErrorResult>) -> ())
}

class AttachmentService: AttachmentServiceProtocol {
    let repository = AttachmentRepository()
    func fetchAttachment(offset: Int, completion: @escaping (Result<[Attachment], ErrorResult>) -> ()) {
        repository.fetchAttachment(offset: offset) { (attachments) in
            completion(.success(attachments))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func fetchAttachment(with id: Int, source: AttachmentSource, completion: @escaping (Result<[Attachment], ErrorResult>) -> ()) {
        repository.fetchAttachment(with: id, source: source) { (attachments) in
            completion(.success(attachments))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func addAttachment(attachment: Attachment, completion: @escaping (Result<String, ErrorResult>) -> ()) {
        repository.addAttachment(attachment: attachment) { id in
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }

    }
    
    func deleteAttachment(attachment: Attachment, completion: @escaping (Result<String, ErrorResult>) -> ()) {
        repository.deleteAttachment(attachment: attachment) {
            completion(.success(""))
        } failure: { (error) in
            completion(.failure(.custom(string: error.localizedDescription)))
        }
    }
}
