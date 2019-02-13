//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Sarah on 1/27/19.
//  Copyright © 2019 Sarah. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest" 

    }
    
    struct ParamterKey {
        static let APIKey = "api_key"
        static let Method = "method"
        static let Format = "format"
        static let Accuracy = "accuracy"
        static let PhotoPerPage = "per_page"
        static let Extra = "extras"
        static let SafeSearch = "safe_search"
        static let NoJSONCallback = "nojsoncallback"
        static let Page = "page"



        
        static let longitude = "lon"
        static let latitude = "lat"

    }
    
    struct ParameterValue{
        static let APIKey = "0444be8db3f490068bd8c94bc3f1fb2c"
        static let SearchMethod = "flickr.photos.search"
        static let Format = "json"
        static let Accuracy = "11"
        static let PhotoPerPage = "27"
        static let MediumURL = "url_m"
        static let SafeSearch = "1"
        static let NoJSONCallback = "1"


    }
    
}
