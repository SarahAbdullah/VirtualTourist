//
//  Photo+Extensions.swift
//  VirtualTourist
//
//  Created by Sarah on 1/27/19.
//  Copyright © 2019 Sarah. All rights reserved.
//

import Foundation
import CoreData

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creatDate = Date()
    }
}
