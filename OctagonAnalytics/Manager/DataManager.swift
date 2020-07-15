//
//  DataManager.swift
//  OctagonAnalytics
//
//  Created by Rameez on 10/23/17.
//  Copyright © 2017 Octagon Mobile. All rights reserved.
//

import UIKit
//import AFNetworking
import Alamofire
import AlamofireImage

typealias CompletionBlock = (_ result: Any?,_ error: NSError?) -> Void

class DataManager: NSObject {
    
    /**
     Returns the shared default object.
     */
    static let shared = DataManager()
    
    fileprivate var sessionManager : SessionManager?
    
    fileprivate var defaultHeaders: HTTPHeaders {
        var headers = ["kbn-xsrf": "reporting"]
        if keyCloakEnabled,
            let accessToken = Session.shared.keyCloakAccessToken {
            headers["Authorization"] = "Bearer \(accessToken)"
        }
        return headers
    }
    
    //MARK: Functions
    override init() {
        super.init()
        DataRequest.addAcceptableImageContentTypes(["image/png","image/jpg", "binary/octet-stream"])

        
//        let serverTrustPolicies: [String: ServerTrustPolicy] = [
//            "BASE_URL": .pinCertificates(
//                certificates: ServerTrustPolicy.certificates(),
//                validateCertificateChain: true,
//                validateHost: true
//            ),
//            "insecure.expired-apis.com": .disableEvaluation
//        ]
        
        self.sessionManager =  SessionManager(configuration: URLSessionConfiguration.default,
                                              serverTrustPolicyManager: nil
        )

//        self.sessionManager =  SessionManager(configuration: URLSessionConfiguration.default,
//                                              serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
//        )
        
    }
    
    /**
     Loads data from server.
     
     - parameter urlComponent: Components to be appended to the base url.
     - parameter methodType: HTTP Method Type (Default value is GET).
     - parameter parameters: Parameters to be passed to server.
     - parameter completion: Call back once the server returns the response.

     */
    func loadData(_ urlComponent: String = "", methodType: HTTPMethod = .get, encoding: ParameterEncoding =  URLEncoding.default, parameters: [String: Any]?, completion:CompletionBlock?) {

        let urlString = Configuration.shared.baseUrl + UrlComponent.defaultComponant
        loadData(url: urlString, urlComponent, methodType: methodType, encoding: encoding, parameters: parameters, completion: completion)
    }
    
    /**
     Loads data from server.
     
     - parameter url: URL string.
     - parameter urlComponent: Components to be appended to the url.
     - parameter methodType: HTTP Method Type (Default value is GET).
     - parameter parameters: Parameters to be passed to server.
     - parameter completion: Call back once the server returns the response.
     
     */
    func loadData(url: String, _ urlComponent: String = "", methodType: HTTPMethod = .get, encoding: ParameterEncoding =  URLEncoding.default, parameters: [String: Any]?, completion:CompletionBlock?) {
        
        func loadData() {
            let urlString = urlComponent.isEmpty ? url : (url + "/" + urlComponent)
            
            guard let url = URL(string: urlString) else {
                let error = NSError(domain: AppName, code: 100, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
                completion?(nil, error)
                return
            }
            
            
            DLog("URL: \(urlString), Params: \(String(describing: parameters))")
            sessionManager?.request(url, method: methodType, parameters: parameters, encoding: encoding, headers: defaultHeaders).validate().responseJSON { [weak self] (response) in
                
                self?.handleResponse(response: response, completion)
            }
        }
        
        guard keyCloakEnabled else {
            loadData()
            return
        }
        Session.shared.refreshToken { (refreshedAccessToken, error) in
            loadData()
        }
    }

    /**
     Loads data from server.
     
     - parameter urlComponent: Components to be appended to the url.
     - parameter queryParametres: Query Parametres to append.
     - parameter methodType: HTTP Method Type (Default value is GET).
     - parameter parameters: Parameters to be passed to server.
     - parameter completion: Call back once the server returns the response.
     
     */
    func loadData(_ urlComponent: String = "", queryParametres: [String: String], methodType: HTTPMethod = .post, encoding: ParameterEncoding =  JSONEncoding.default, parameters: [String: Any]?, completion:CompletionBlock?) {
        
        func loadData() {
            let baseUrl = Configuration.shared.baseUrl + UrlComponent.defaultComponant
            let urlString = urlComponent.isEmpty ? baseUrl : (baseUrl + "/" + urlComponent)

            guard let url = URL(string: urlString), let computedUrl = url.URLByAppendingQueryParameters(queryParametres) else {
                let error = NSError(domain: AppName, code: 100, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
                completion?(nil, error)
                return
            }

            DLog("URL: \(urlString), Params: \(String(describing: parameters))")
            sessionManager?.request(computedUrl, method: methodType, parameters: parameters, encoding: encoding, headers: defaultHeaders).validate().responseJSON { [weak self] (response) in

                self?.handleResponse(response: response, completion)
            }
        }

        guard keyCloakEnabled else {
            loadData()
            return
        }
        Session.shared.refreshToken { (refreshedAccessToken, error) in
            loadData()
        }
    }
    /**
     Loads XML data from server.
     
     - parameter baseUrl: base url.(Default : Map Url)
     - parameter methodType: HTTP Method Type (Default value is GET).
     - parameter parameters: Parameters to be passed to server.
     - parameter completion: Call back once the server returns the response.
     
     */
    func loadXMLData(baseUrl: String =  Configuration.shared.environment.mapBaseUrl, methodType: HTTPMethod = .get, encoding: ParameterEncoding =  URLEncoding.default, parameters: [String: Any]?, completion:CompletionBlock?) {
        let urlString = baseUrl
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: AppName, code: 100, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion?(nil, error)
            return
        }
        
        sessionManager?.request(url, method: methodType, parameters: parameters, encoding: encoding, headers: nil).validate().responseData(completionHandler: { [weak self] (response) in
            
            
            self?.handleResponse(response: response, completion)

        })
    }
    
    /**
     Loads Image from server.
     
     - parameter imageUrl: url of the image to be loaded
     - parameter completion: Call back once the server returns the image.
     
     */
    func loadImage(imageUrl: String, completionHandler: CompletionBlock?){
        _ = Alamofire.request(imageUrl, method: .get).responseImage { response in
            
            guard response.result.error == nil else {
                let error = NSError(domain: AppName, code: 100, userInfo: [NSLocalizedDescriptionKey: response.result.error?.localizedDescription ?? "Invalid Response"])
                completionHandler?(nil, error)
                return
            }
            guard let image = response.result.value else {
                let error = NSError(domain: AppName, code: 100, userInfo: [NSLocalizedDescriptionKey: "Invalid Response"])
                completionHandler?(nil, error)
                return
            }
            completionHandler?(image, nil)
        }
    }

    //MARK: Private Functions
    
    /**
     Handles the response/error returned.
     
     - parameter completion: Call back after parsing the response/error.
     */
    fileprivate func handleResponse<T>(response: DataResponse<T>,_ completion:CompletionBlock?) {
        
        guard response.result.isSuccess else {
            var error: NSError?
            if let responseData = response.data, let responseDict = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any?], let message =  responseDict["message"] as? String {
                let code = responseDict["statusCode"] as? Int ?? 100
                
                if code == ErrorCode.unAuthorized {
                    let sessionTimeOut = Notification(name: Notification.Name(rawValue: Constant.sessionTimeOutNotification), object: error, userInfo: [NSLocalizedDescriptionKey: message])
                    NotificationCenter.default.post(sessionTimeOut)
                }
                error = NSError(domain: AppName, code: code, userInfo: [NSLocalizedDescriptionKey: message])
            } else {
                error = response.result.error as NSError?
            }
            completion?(nil, error)
            
            DLog("Error while loading data: \(error?.localizedDescription ?? ""))")
            return
        }
        
        
        guard let _ = response.result.value else {
            let error = NSError(domain: AppName, code: 100, userInfo: [NSLocalizedDescriptionKey: "Invalid Response"])
            completion?(nil, error)
            return
        }
        
        DLog(String(describing: response.response?.allHeaderFields))

        DLog(String(describing: response.result.value))
        
        let finalResponse: [AnyHashable: Any?] = ["result": response.result.value,
                                                  "header": response.response?.allHeaderFields]
        
        completion?(finalResponse, nil)
        
    }
}

extension DataManager {
    struct UrlComponent {
        static let defaultComponant = "/api"
    }
    
    struct ErrorCode {
        static let unAuthorized = 403
    }
}

struct Constant {
    static let sessionTimeOutNotification = "sessionTimeOutNotification"
}
