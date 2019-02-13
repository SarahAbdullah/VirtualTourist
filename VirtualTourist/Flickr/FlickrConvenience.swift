//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Sarah on 1/27/19.
//  Copyright © 2019 Sarah. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func getPageNumber()-> Int{
        if let total = self.totalPages {
        let range = min( total , 4000/27)
        let page = Int(arc4random() % UInt32(range))
            return page }
        
            return 1
    }

    func searchPhotos(longitude: Double , latitude: Double,_ completionHandlerForSearchPhotos: @escaping (_ success: Bool,_ isEmpty: Bool ,_ resultPhotos: [[String:AnyObject]]? , _ errorString: String?) -> Void) {
        //ParameterValue
        let pageNumber = getPageNumber()

        let Parameters = [FlickrClient.ParamterKey.APIKey : FlickrClient.ParameterValue.APIKey ,
                          FlickrClient.ParamterKey.Method : FlickrClient.ParameterValue.SearchMethod,
                          FlickrClient.ParamterKey.Format : FlickrClient.ParameterValue.Format,
                          FlickrClient.ParamterKey.Accuracy : FlickrClient.ParameterValue.Accuracy,
                          FlickrClient.ParamterKey.PhotoPerPage : FlickrClient.ParameterValue.PhotoPerPage,
                          FlickrClient.ParamterKey.Extra : FlickrClient.ParameterValue.MediumURL,
                          FlickrClient.ParamterKey.SafeSearch : FlickrClient.ParameterValue.SafeSearch,
                          FlickrClient.ParamterKey.NoJSONCallback : FlickrClient.ParameterValue.NoJSONCallback,
                          FlickrClient.ParamterKey.Page : "\(pageNumber)" ,
                          FlickrClient.ParamterKey.longitude : longitude,
                          FlickrClient.ParamterKey.latitude : latitude ]  as [String : AnyObject ]
        
        let _ = taskForGETMethod(Parameters ) { (result , error) in
            
            if let error = error {
                completionHandlerForSearchPhotos(false ,false, nil,error.localizedDescription)
            }else {
                if let result = result!["photos"] as? [String:AnyObject],let photos = result["photo"] as? [[String:AnyObject]] {
                    if photos.isEmpty{
                        completionHandlerForSearchPhotos(true ,true,nil,nil) }
                    else{
                        completionHandlerForSearchPhotos(true ,false, photos, nil )
                    }
                }
                
                
            }
        }
        
    }
    
    func getTotalPages(longitude: Double , latitude: Double , _ completionHandlerForGetPhotos: @escaping (_ success: Bool,_  assignTotal :  Bool, _ errorString: String?) -> Void) {
        //ParameterValue

        let Parameters = [FlickrClient.ParamterKey.APIKey : FlickrClient.ParameterValue.APIKey ,
                          FlickrClient.ParamterKey.Method : FlickrClient.ParameterValue.SearchMethod,
                          FlickrClient.ParamterKey.Format : FlickrClient.ParameterValue.Format,
                          FlickrClient.ParamterKey.Accuracy : FlickrClient.ParameterValue.Accuracy,
                          FlickrClient.ParamterKey.PhotoPerPage : FlickrClient.ParameterValue.PhotoPerPage,
                          FlickrClient.ParamterKey.Extra : FlickrClient.ParameterValue.MediumURL,
                          FlickrClient.ParamterKey.SafeSearch : FlickrClient.ParameterValue.SafeSearch,
                          FlickrClient.ParamterKey.NoJSONCallback : FlickrClient.ParameterValue.NoJSONCallback,
                          FlickrClient.ParamterKey.longitude : longitude,
                          FlickrClient.ParamterKey.latitude : latitude ]  as [String : AnyObject ]
        
        let _ = taskForGETMethod(Parameters ) { (result , error) in
            
            if let error = error {
                completionHandlerForGetPhotos(false , false, error.localizedDescription)

            }else {
                if let result = result!["photos"] as? [String:AnyObject] , let photos = result["photo"] as? [[String:AnyObject]] {
                    if photos.isEmpty{
                        completionHandlerForGetPhotos(true ,false,nil) }
                    else{
                        let total = result["total"]  as? String
                        self.totalPages = Int(total!)
                        completionHandlerForGetPhotos(true , true, nil )
                    }
                }
                
                
            }
        }
        
    }

}
