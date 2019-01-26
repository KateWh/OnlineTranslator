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
            historyNewItem.setValue(false, forKey: "bookmark")
            ruID! += 1
        } else if lang == "en" {
            historyNewItem.setValue(data, forKey: "en")
            historyNewItem.setValue(enID, forKey: "enID")
            historyNewItem.setValue(false, forKey: "bookmark")
            enID! += 1
        }
        
        do {
            try managedContext.save()
        } catch {
            print("Could not save. \(error), \(String(describing: error._userInfo))")
        }
   }
    
    // Retrieve Data from storage
     func getHistory(lang: String) -> [HasFavorite] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [HasFavorite]() }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        var historyArr = [HasFavorite]()
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                if lang == "ru" {
                    if data.value(forKey: "ru") as? String != nil {
                        historyArr.append(HasFavorite(value: data.value(forKey: "ru") as! String , favoriteFlag: data.value(forKey: "bookmark") as! Bool))
                    }
                } else if lang == "en" {
                    if data.value(forKey: "en") as? String != nil {
                        historyArr.append(HasFavorite(value: data.value(forKey: "en") as! String, favoriteFlag: data.value(forKey: "bookmark") as! Bool))
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
    
    public func setBookmark(forValue cellString: String, bookmark: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                if data.value(forKey: "ru") as? String == cellString {
                    data.setValue(bookmark, forKey: "bookmark")
                } else if data.value(forKey: "en") as? String == cellString {
                    data.setValue(bookmark, forKey: "bookmark")
                }
            }
        } catch {
            print("")
        }
        

        do {
            try managedContext.save()
        } catch {
            print(error)
        }
        
    }
    

    func getBookmarks() -> [HasFavorite] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        var bookmarksArray = [HasFavorite]()
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                if data.value(forKey: "bookmark") as? Bool == true && data.value(forKey: "ru") != nil{
                    bookmarksArray.append(HasFavorite(value: data.value(forKey: "ru") as! String, favoriteFlag: data.value(forKey: "bookmark") as! Bool ))
                } else if data.value(forKey: "bookmark") as? Bool == true && data.value(forKey: "en") != nil {
                    bookmarksArray.append(HasFavorite(value: data.value(forKey: "en") as! String, favoriteFlag: data.value(forKey: "bookmark") as! Bool ))                }
            }
        } catch {
            print(error)
        }
        return bookmarksArray
    }

    func deleteBookmarks(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                data.setValue(false, forKey: "bookmark")
            }
        } catch {
            print("")
        }


        do {
            try managedContext.save()
        } catch {
            print(error)
        }
    }

}


