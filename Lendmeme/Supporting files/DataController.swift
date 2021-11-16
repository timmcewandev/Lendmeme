//
//  DataController.swift
//  Virtual Tourist
//
//  Created by sudo on 5/17/18.
//  Copyright © 2018 sudo. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    var viewContext:NSManagedObjectContext {
        return persistantContainer.viewContext
    }
    
    let persistantContainer:NSPersistentContainer
    init(modelName: String) {
        persistantContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: (() -> Void)? = nil) {
        persistantContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext(interval: 30)
            completion?()
        }
    }
}

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        guard interval > 0 else { return }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}
