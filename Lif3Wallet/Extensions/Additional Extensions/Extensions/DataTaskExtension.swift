////
////  DataTaskExtension.swift
////  DoCo22
////
////  Created by EKbana MacMini 2018 on 2/19/20.
////  Copyright © 2020 ekbana. All rights reserved.
////
//
//import Foundation
//
//extension URLSession {
//    
//    struct File {
//        let name: String
//        let fileName: String
//        let data: Data
//        let contentType: String
//    }
//    
//    @discardableResult
//    func dataTask<T:Codable>(request: BookGaraRequest, success: @escaping (T) -> (), failure: @escaping (Error) -> ()) -> URLSessionDataTask {
//        let task = dataTask(with: request.request) { [weak self] (data, response, error) in
//            self?.handle(data: data, response: response, error: error, success: { (successData: SingleContainer<T>) in
////                debugPrint(request.request.url?.absoluteURL ?? "")
//                request.cache(data: successData)
//                success(successData.data!)
//            }, failure: { error in
////                debugPrint(request.request.url?.absoluteURL ?? "")
//                if (error as NSError).code == -1009,
//                    let cached: SingleContainer<T> = request.cached() {
//                    return success(cached.data!)
//                }
//                
//                //specific case for book gara treated as success
//                if T.self == String.self {
//                    if (error as NSError).code == 200 {
//                        success(error.localizedDescription as! T )
//                    }
//                }
//                failure(error)
//            })
//        }
//        task.resume()
//        return task
//    }
//    
////    @discardableResult
////    func dataTask<T: Codable>(request: BookGara, success: @escaping ([T], Pagination?) -> (), failure: @escaping (Error) -> ()) -> URLSessionDataTask {
////        let task = dataTask(with: request.request) { [weak self] (data, response, error) in
////            self?.handle(data: data, response: response, error: error, success: { (successData: ArrayContainer<T>) in
////                debugPrint(request.request.url?.absoluteURL ?? "")
////                request.cache(data: successData)
////                success(successData.data ?? [], successData.meta?.pagination)
////            }, failure: { error in
////                debugPrint(request.request.url?.absoluteURL ?? "")
////                if (error as NSError).code == -1009,
////                    let cached: ArrayContainer<T> = request.cached() {
////                    var pagination = cached.meta?.pagination
////                    pagination?.isFromOffline = true
////                    return success(cached.data!, pagination)
////                }
////                failure(error)
////            })
////        }
////        task.resume()
////        return task
////    }
//    
//    @discardableResult
//    func upload<T: Codable>(request: BookGaraRequest, params: [String: String], files: [File], success: @escaping (T) -> (), failure: @escaping (Error) -> ()) -> URLSessionUploadTask {
//        //        let url = URL(string: "http://api-host-name/v1/api/uploadfile/single")
//        
//        // generate boundary string using a unique per-app string
//        let boundary = UUID().uuidString
//        
//        // Set the URLRequest to POST and to the specified URL
//        var urlRequest = request.request
//        
//        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
//        // And the boundary is also set here
//        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//        let data = createBodyWithParameters(parameters: params, files: files, boundary: boundary)
//        
//        // Send a POST request to the URL, with the data we created earlier
//        let task = uploadTask(with: urlRequest, from: data) { [weak self] (data, response, error) in
//            self?.handle(data: data, response: response, error: error, success: { (successData: SingleContainer<T>) in
//                success(successData.data!)
//            }, failure: failure)
//        }
//        task.resume()
//        return task
//    }
//    
//    private func createBodyWithParameters(parameters: [String: String], files: [File], boundary: String) -> Data {
//        var body = Data()
//        for (key, value) in parameters {
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
//            body.append("\(value)\r\n".data(using: .utf8)!)
//        }
//        for file in files {
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.fileName)\"\r\n".data(using: .utf8)!)
//            body.append("Content-Type: \(file.contentType)\r\n\r\n".data(using: .utf8)!)
//            body.append(file.data)
//            body.append("\r\n".data(using: .utf8)!)
//        }
//        
//        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//        return body
//    }
//    
//    private func handle<T: Container>(data: Data?, response: URLResponse?, error: Error?, success: @escaping (T)->(), failure: @escaping (Error) -> ()) {
//        func send(error: Error) {
//            DispatchQueue.main.async {
//                failure(error)
//            }
//        }
//        
//        func send(object: T) {
//            DispatchQueue.main.async {
//                success(object)
//            }
//        }
//        
//        if (error as NSError?)?.code == -999 {return}
//        
//        if let error = error {
//            return send(error: error)
//        }
//        
//        print("Header: \(CurrentHeaderBodyParameter.request?.allHTTPHeaderFields ?? [:])\nURL: \n\(CurrentHeaderBodyParameter.request?.url?.relativeString ?? "")\n Parameters: \n\(CurrentHeaderBodyParameter.body ?? [:])\n Response: \n\(data?.jsonString ?? "")")
//        let statuscode = (response as? HTTPURLResponse)?.statusCode ?? 500
//        if let data = data {
//            do {
//                let decoder = JSONDecoder()
////                decoder.keyDecodingStrategy = .convertFromSnakeCase
//                let container = try decoder.decode(T.self, from: data)
//                if let error = container.error?.errorFormat {
//                    if statuscode == 401 {
//                        NotificationCenter.default.post(name: .unauthorized, object: error)
//                        return
//                    }
//                    return send(error: error)
//                }
//                if container.hasData {
//                    return send(object: container)
//                }
//                
//                // only for bookgara
//                if let successMessage = container.successMessage  {
//                    return send(error:  NSError(domain: "Success Message", code: 200, userInfo: [NSLocalizedDescriptionKey: successMessage]))
//                }
//            } catch {
//                debugPrint(error)
//            }
//        }
//        if statuscode == 401 {
//            NotificationCenter.default.post(name: .unauthorized, object: nil)
//            return
//        }
//        return send(error: GlobalConstants.Error.oops)
//    }
//}
//
//func generic<T>(parameter: AnyObject, type: T.Type) -> Bool {
//    if parameter is T {
//        return true
//    } else {
//        return false
//    }
//}
