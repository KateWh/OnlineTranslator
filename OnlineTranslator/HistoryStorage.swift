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
    var counterFlag = false
    
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
    
    func fetchEntity(_ completionHandler: @escaping ([NSManagedObject]) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LifeCounter")
        
        do {
            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            completionHandler(result)
        } catch {
            print("error")
        }
        
    }

    // Write data
    public func createData(from data: String, at lang: String) {
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
    public func getHistory(lang: String) -> [String] {
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
            let objectUpdate = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            if objectUpdate != [] {
                for object in objectUpdate {
                    object.setValue(countTranslate, forKey: "countTranslate")
                }
            } else {
                timerObject.setValue(countTranslate, forKey: "countTranslate")
            }
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
            let timerString = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            objectReturn = timerString.last?.value(forKey: "countTranslate") as? Int ?? 0
        } catch {
            print( "O боже где count 😧")
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
                if (historyItem.value(forKey: lang) as? String)  != nil  {
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
        
        return counter
    }
    
    public func setBookmark(forValue cellString: String, at lang: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let ruBookmarksEntity = NSEntityDescription.entity(forEntityName: "RuBookmarks", in: managedContext)!
        let enBookmarksEntity = NSEntityDescription.entity(forEntityName: "EnBookmarks", in: managedContext)!
        let newRuBookmark = NSManagedObject(entity: ruBookmarksEntity, insertInto: managedContext)
        let newEnBookmark = NSManagedObject(entity: enBookmarksEntity, insertInto: managedContext)
        
        if lang == "ru" {
            newRuBookmark.setValue(String(cellString), forKey: "bookmark")
        } else if lang == "en" {
            newEnBookmark.setValue(String(cellString), forKey: "bookmark")
        }
        
        do {
            try managedContext.save()
        } catch {
            print(error)
        }
        
    }
    
    
    func getBookmarks() -> [String] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RuBookmarks")
        var bookmarksArray = [String]()
        
        do {
            let bookmarkTable = try managedContext.fetch(fetchRequest)
            for bookmarkRow in bookmarkTable as! [NSManagedObject] {
                if let bookmark = bookmarkRow.value(forKey: "bookmark") {
                    bookmarksArray.append(bookmark as! String)
                }
            }
        } catch {
            print(error)
        }
        return bookmarksArray
    }

    func deleteBookmarks(atLang lang: String) -> Int {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return 0 }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRu = NSFetchRequest<NSFetchRequestResult>(entityName: "RuBookmarks")
        let fetchEn = NSFetchRequest<NSFetchRequestResult>(entityName: "EnBookmarks")
        let requestRu = NSBatchDeleteRequest(fetchRequest: fetchRu)
        let requestEn = NSBatchDeleteRequest(fetchRequest: fetchEn)
        var counterOfBookmarks = -1

        do {
            let ruBookmarksTable = try managedContext.fetch(fetchRu)
            let enBookmarksTable = try managedContext.fetch(fetchEn)
            
            if lang == "ru" {
                for _ in ruBookmarksTable as! [NSManagedObject] {
                    counterOfBookmarks += 1
                }
                try managedContext.execute(requestRu)
            } else if lang == "en" {
                for _ in enBookmarksTable as! [NSManagedObject] {
                    counterOfBookmarks += 1
                }
                try managedContext.execute(requestEn)
            }
            
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
            
        } catch {
            print(error)
        }
        return counterOfBookmarks
    }
    
}


