//
//  LocationsList.swift
//  Locations
//
//  Created by Sujit Molleti on 7/12/20.
//  Copyright © 2020 Sujit Molleti. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class LocationList {
    
    private static var instance = LocationList()
    private var locations: [SavedLocation] = []
    
    private init(){
        
    }
    
    static func getInstance() -> LocationList{
        return instance
    }
    
    func saveLocation(coordinate: namedCoordinate){
        //1 Getting context of persistent container inside the app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2 Links entity to NSManagedObject at runtime
        let entity = NSEntityDescription.entity(forEntityName: "SavedLocation", in: managedContext)!
        let location = NSManagedObject(entity: entity, insertInto: managedContext)

        //3 Inserting the paramter into the NSManagedObject that we created in step 2
        location.setValue(coordinate, forKey: "coordinate")
        
        //4 Appending the new object, surround in do-catch bc managedContext.save throws an error
        do {
            try managedContext.save()
            locations.append(location as! SavedLocation) //must specify type as we did in the xcdatamodel file
            print("savedList")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        

    }
    
    func loadLocations(){
        //1 Get reference to persistentContainter context from the app Delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2 Fetch Request
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SavedLocation")
        
        //3 Load the list
        do{
            locations = try (managedContext.fetch(fetchRequest) as! [SavedLocation])
            print("listLoaded")
        } catch let error as NSError {
            print("Could not fetch. \(error)")
        }
        
    }
    
    
}
