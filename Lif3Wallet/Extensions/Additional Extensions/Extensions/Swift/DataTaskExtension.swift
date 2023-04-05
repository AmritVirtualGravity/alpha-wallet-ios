//
//  DataTaskExtension.swift
//  DoCo22
//
//  Created by EKbana MacMini 2018 on 2/19/20.
//  Copyright © 2020 ekbana. All rights reserved.
//

import Foundation

extension URLSession {
    
    struct File {
        let name: String
        let fileName: String
        let data: Data
        let contentType: String
    }
    
    @discardableResult
    func dataTask<T:Codable>(request: AppRequest, success: @escaping (T) -> (), failure: @escaping (Error) -> ()) -> URLSessionDataTask {
        let task = dataTask(with: request.request) { [weak self] (data, response, error) in
//            self?.handle(data: data, response: response, error: error, success: { (successData: SingleContainer<T>) in
            self?.handle(data: data, response: response, error: error, success: { (successData: T) in
//                debugPrint(request.request.url?.absoluteURL ?? "")
                request.cache(data: successData)
                success(successData)
            }, failure: { error in
//                debugPrint(request.request.url?.absoluteURL ?? "")
                if (error as NSError).code == -1009,
                   let cached: T = request.cached() {
                    return success(cached)
                }
//                if error as NSObject == GlobalConstants.Error.emptyData {
//                    //                    success([])
//                    let emptyData = SingleContainer<T>(body: nil, status: 212, message: "Data is Empty", error: "Data is Empty")
//                    return success(emptyData)
//                }
                failure(error)
            })
        }
        task.resume()
        return task
    }
    
    @discardableResult
    func upload<T: Codable>(request: AppRequest, params: [String: String], files: [File], success: @escaping (T) -> (), failure: @escaping (Error) -> ()) -> URLSessionUploadTask {
        //        let url = URL(string: "http://api-host-name/v1/api/uploadfile/single")

        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString

        // Set the URLRequest to POST and to the specified URL
        var urlRequest = request.request

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let data = createBodyWithParameters(parameters: params, files: files, boundary: boundary)

        // Send a POST request to the URL, with the data we created earlier
        let task = uploadTask(with: urlRequest, from: data) { [weak self] (data, response, error) in
            self?.handle(data: data, response: response, error: error, success: { (successData: SingleContainer<T>) in
                success(successData.data!)
            }, failure: failure)
        }
        task.resume()
        return task
    }
    
    private func createBodyWithParameters(parameters: [String: String], files: [File], boundary: String) -> Data {
        var body = Data()
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        for file in files {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(file.contentType)\r\n\r\n".data(using: .utf8)!)
            body.append(file.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    private func handle<T: Codable>(data: Data?, response: URLResponse?, error: Error?, success: @escaping (T)->(), failure: @escaping (Error) -> ()) {
        func send(error: Error) {
            DispatchQueue.main.async {
                failure(error)
            }
        }
        
        func send(object: T) {
            DispatchQueue.main.async {
                success(object)
            }
        }
        
        if (error as NSError?)?.code == -999 { return }
        if let error = error {
            return send(error: error)
        }
        
        print("Header: \(CurrentHeaderBodyParameter.request?.allHTTPHeaderFields ?? [:])\nURL: \n\(CurrentHeaderBodyParameter.request?.url?.relativeString ?? "")\n Parameters: \n\(CurrentHeaderBodyParameter.body ?? [:])\n Response: \n\(data?.jsonString ?? "")")
        
        CurrentHeaderBodyParameter.request = nil
        CurrentHeaderBodyParameter.body = nil
        CurrentHeaderBodyParameter.header = nil
        var messageString: String? = nil
        if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                let dict = json as? Dictionary<String, Any>
//                 messageString = dict?["message"] as? String
                
                let decoder = JSONDecoder()
                let container = try decoder.decode(T.self, from: data)
                return send(object: container)
            } catch let parsingError {
                debugPrint(error ?? parsingError)
                return send(error: messageString == nil ? parsingError :  NSError(domain: "Error Message", code: 500, userInfo: [NSLocalizedDescriptionKey: parsingError.localizedDescription ]) )
       
            }
        }
        return send(error: GlobalConstants.Error.oops)
    }
    
}

func generic<T>(parameter: AnyObject, type: T.Type) -> Bool {
    if parameter is T {
        return true
    } else {
        return false
    }
}
