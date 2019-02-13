//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Sarah on 1/27/19.
//  Copyright © 2019 Sarah. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {

    // shared session
    var session = URLSession.shared
    
    var totalPages : Int!
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    // MARK: GET
    
    func taskForGETMethod(_ parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var MethodAndParameters = parameters
        
        let request = NSMutableURLRequest(url: tmdbURLFromParameters(MethodAndParameters) ) 
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard error == nil else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
        
        return task
    }

    // create a URL from parameters
    private func tmdbURLFromParameters(_ parameters: [String:Any] ) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickrClient.Constants.ApiScheme
        components.host = FlickrClient.Constants.ApiHost
        components.path = FlickrClient.Constants.ApiPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
 
    }
    
    
    //convert Data from JSON to a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data , completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
            completionHandlerForConvertData(obj , nil)
            
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
    }
    // MARK: Shared Instance
    
//    class func sharedInstance() -> FlickrClient {
//        struct Singleton {
//            static var sharedInstance = FlickrClient()
//        }
//        return Singleton.sharedInstance
//    }
    
    static let sharedInstance = FlickrClient()
    

    
}
