//
//  DataController.swift
//  VirtualTourist
//
//  Created by Sarah on 1/26/19.
//  Copyright © 2019 Sarah. All rights reserved.


import Foundation
import CoreData

class DataController {
    //1- hold a Persistent Container instance
    let presistentcontair : NSPersistentContainer
    
    //3- access the context
    var viewContext: NSManagedObjectContext {
        return presistentcontair.viewContext
    }
    var backgroundContext : NSManagedObjectContext!
    
    init(modelName: String){
        presistentcontair = NSPersistentContainer(name: modelName )
    }
    
    func configureContexts(){
        backgroundContext = presistentcontair.newBackgroundContext()
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    // 2-load the Persistent Stores
    //optional closer : if i want to do somrthing after load success
    func load(complation: (()-> Void)? = nil ){
        presistentcontair.loadPersistentStores { storesDescripation , error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            complation?()
        }
        
    }
    
}

extension DataController {
    func autoSaveViewContext(interval : TimeInterval = 30){
        print("autoSaveViewContext() has been call")
        guard interval > 0 else{
            return
        }
        if viewContext.hasChanges{
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+interval ){
            self.autoSaveViewContext(interval: interval)
        }
        
    }
}
