//
//  CoreData.swift
//  OnlineTranslator
//
//  Created by vitket team on 1/4/19.
//  Copyright © 2019 vitket team. All rights reserved.
//
import UIKit
import CoreData

// History Storage Class
public class HistoryStorage {
    var ruID: Int? = nil
    var enID: Int? = nil
    var timerIsTrue = false
    
    init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        var ruIDarr: [Int]?
        var enIDarr: [Int]?
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for item in result as! [NSManagedObject] {
                if let ruIdItem = item.value(forKey: "ruID") as? Int {
                    ruIDarr?.append(ruIdItem)
                }
                if let enIdItem = item.value(forKey: "enID") as? Int {
                    enIDarr?.append(enIdItem)
                }
            }

            ruID = ruIDarr?.max() ?? 0
            enID = enIDarr?.max() ?? 0
        } catch {
            print(error)
        }
    }
    
    func CCCP() -> [String:Int] {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LifeCounter")
        let managedContext = appDelegate!.persistentContainer.viewContext
        var timer = [String:Int]()
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if result == [] {
                timer.merge(["countTranslations" : 0], uniquingKeysWith: {(current, _) in current})
                timer.merge(["date" : 6], uniquingKeysWith: {(current, _) in current})            }
            for object in result {
            timer.merge(["countTranslations": object.value(forKey: "countTranslate") as? Int ?? 0], uniquingKeysWith: { (current, _) in current })
            timer.merge(["date": object.value(forKey: "date") as? Int ?? 0], uniquingKeysWith: { (current, _) in current })
            }
        } catch {
            print(error)
        }
        return timer
    }

    // Write data
    public func createData(from data: String, lang: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        //let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        let historyEntity = NSEntityDescription.entity(forEntityName: "History", in: managedContext)!
        let historyNewItem = NSManagedObject(entity: historyEntity, insertInto: managedContext)

        // write RU or EN to entity
        if lang == "ru" {
            historyNewItem.setValue(data, forKey: "ru")
            historyNewItem.setValue(ruID, forKey: "ruID")
            ruID! += 1
        } else if lang == "en" {
            historyNewItem.setValue(data, forKey: "en")
            historyNewItem.setValue(enID, forKey: "enID")
            enID! += 1
        }
        
        do {
            try managedContext.save()
        } catch {
            print("Could not save. \(error), \(String(describing: error._userInfo))")
        }
   }
    
    // Retrieve Data from storage
    public func retrieveData(lang: String) -> [String] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return ["Error"] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        var historyArr = [String]()
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                if lang == "ru" {
                    if data.value(forKey: "ru") as? String != nil {
                        historyArr.append(data.value(forKey: "ru") as! String)
                    }
                } else if lang == "en" {
                    if data.value(forKey: "en") as? String != nil {
                        historyArr.append(data.value(forKey: "en") as! String)
                    }
                }
            }
        } catch {
            print("Failed")
        }
        return historyArr
    }
    
    
    // Save count translate
    public func saveCountTranslate(countTranslate: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LifeCounter")

        let timerTable = NSEntityDescription.entity(forEntityName: "LifeCounter", in: managedContext)!
        let timerObject = NSManagedObject(entity: timerTable, insertInto: managedContext)

        do {
            let object = try managedContext.fetch(fetchRequest)
            let objectUpdate = object[0] as! NSManagedObject
            if objectUpdate.value(forKey: "countTranslate") as? String != nil {
                objectUpdate.setValue(countTranslate, forKey: "countTranslate")
            } else {
                timerObject.setValue(countTranslate, forKey: "countTranslate")
            }
            timerIsTrue = true
        } catch {
            print("save counter not found")
        }
    }

    // Retrieve count translate
    public func getCountTranslate() -> Int {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return 0 }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LifeCounter")
        var objectReturn = 0
         do {
            let timerString = try managedContext.fetch(fetchRequest)
            for object in timerString as! [NSManagedObject] {
                objectReturn = object.value(forKey: "countTranslate") as! Int
            }
        } catch {
            print( "O боже где count 😧")
        }
        return objectReturn
    }
    
    // Save date
    public func saveDate(date: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LifeCounter")

        let timerTable = NSEntityDescription.entity(forEntityName: "LifeCounter", in: managedContext)!
        let timerObject = NSManagedObject(entity: timerTable, insertInto: managedContext)

        do {
            let object = try managedContext.fetch(fetchRequest)
            let objectUpdate = object[0] as! NSManagedObject
            if objectUpdate.value(forKey: "date") as? String != nil {
                objectUpdate.setValue(date, forKey: "date")
            } else {
                timerObject.setValue(date, forKey: "date")
            }
            timerIsTrue = true
        } catch {
            print("save data not found")
        }

    }
    
    // Retrieve date 
    public func getDate() -> Int {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return 0 }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LifeCounter")
        var objectReturn = 0
        do {
            let timerString = try managedContext.fetch(fetchRequest)
            for object in timerString as! [NSManagedObject] {
                objectReturn = object.value(forKey: "date") as! Int
            }
        } catch {
            print( "O боже где date 😧")
        }
        return objectReturn
    }
    
    // ===================== DELETE HISTORY ================================
    public func deleteHistory(at lang: String) -> Int {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return -1 }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        var counter = -1

        do {
            let historyTable = try managedContext.fetch(fetchRequest)
            for historyItem in historyTable as! [NSManagedObject] {
                if (historyItem.value(forKey: "ruID") as? Int)  != nil  {
                    managedContext.delete(historyItem)
                    counter += 1
                } else if (historyItem.value(forKey: "enID") as? Int)  != nil  {
                    managedContext.delete(historyItem)
                    counter += 1
                }
            }
 
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
        print(counter)
        return counter
    }
    
    
    
    
    
}


