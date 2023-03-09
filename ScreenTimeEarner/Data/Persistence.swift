//
//  Persistence.swift
//  ScreenTimeEarner
//
//  Created by Payton Sides on 3/6/23.
//

import CoreData
import CloudKit
import SwiftUI

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()

    var ckContainer: CKContainer {
      let storeDescription = container.persistentStoreDescriptions.first
      guard let identifier = storeDescription?.cloudKitContainerOptions?.containerIdentifier else {
        fatalError("Unable to get container identifier")
      }
      return CKContainer(identifier: identifier)
    }
    
    var context: NSManagedObjectContext {
      container.viewContext
    }
    
    static var preview: PersistenceController = {
        let result = PersistenceController()
        let viewContext = result.container.viewContext
        for _ in 0..<2 {
            let newItem = Child(context: viewContext)
            newItem.timestamp = Date()
            newItem.id = UUID()
            newItem.name = "Jake Sides"
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    private var _privatePersistentStore: NSPersistentStore?
    private var _sharedPersistentStore: NSPersistentStore?
    
    var privatePersistentStore: NSPersistentStore {
      guard let privateStore = _privatePersistentStore else {
        fatalError("Private store is not set")
      }
      return privateStore
    }
    
    var sharedPersistentStore: NSPersistentStore {
      guard let sharedStore = _sharedPersistentStore else {
        fatalError("Shared store is not set")
      }
      return sharedStore
    }
    
    let storeURL: URL
    let storeDescription: NSPersistentStoreDescription
    
    lazy var container: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: Config.database)

      guard let privateStoreDescription = container.persistentStoreDescriptions.first else {
        fatalError("Unable to get persistentStoreDescription")
      }
      let storesURL = privateStoreDescription.url?.deletingLastPathComponent()
      privateStoreDescription.url = storesURL?.appendingPathComponent("private.sqlite")
      let sharedStoreURL = storesURL?.appendingPathComponent("shared.sqlite")
      guard let sharedStoreDescription = privateStoreDescription.copy() as? NSPersistentStoreDescription else {
        fatalError("Copying the private store description returned an unexpected value.")
      }
      sharedStoreDescription.url = sharedStoreURL

      guard let containerIdentifier = privateStoreDescription.cloudKitContainerOptions?.containerIdentifier else {
        fatalError("Unable to get containerIdentifier")
      }
      let sharedStoreOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
      sharedStoreOptions.databaseScope = .shared
      sharedStoreDescription.cloudKitContainerOptions = sharedStoreOptions
      container.persistentStoreDescriptions.append(sharedStoreDescription)

      container.loadPersistentStores { loadedStoreDescription, error in
        if let error = error as NSError? {
          fatalError("Failed to load persistent stores: \(error)")
        } else if let cloudKitContainerOptions = loadedStoreDescription.cloudKitContainerOptions {
          guard let loadedStoreDescritionURL = loadedStoreDescription.url else {
            return
          }

          if cloudKitContainerOptions.databaseScope == .private {
            let privateStore = container.persistentStoreCoordinator.persistentStore(for: loadedStoreDescritionURL)
            self._privatePersistentStore = privateStore
          } else if cloudKitContainerOptions.databaseScope == .shared {
            let sharedStore = container.persistentStoreCoordinator.persistentStore(for: loadedStoreDescritionURL)
            self._sharedPersistentStore = sharedStore
          }
        }
      }

      container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
      container.viewContext.automaticallyMergesChangesFromParent = true
      do {
        try container.viewContext.setQueryGenerationFrom(.current)
      } catch {
        fatalError("Failed to pin viewContext to the current generation: \(error)")
      }

      return container
    }()
    
    init(defaults: UserDefaults = .standard) {
        storeURL = URL.storeURL(for: Config.appGroupIDID, databaseName: Config.database)
//        container = NSPersistentCloudKitContainer(name: Config.database)
        storeDescription = NSPersistentStoreDescription(url: storeURL)
//        container.persistentStoreDescriptions = [storeDescription]
        storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: Config.containerID)

        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSObject, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                print("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
        
//        container.viewContext.automaticallyMergesChangesFromParent = true
//        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
    }

    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
}

public extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}

// MARK: Share a record from Core Data
@available(watchOSApplicationExtension 8.0, *)
extension PersistenceController {
  func isShared(object: NSManagedObject) -> Bool {
    isShared(objectID: object.objectID)
  }

  func canEdit(object: NSManagedObject) -> Bool {
    return container.canUpdateRecord(forManagedObjectWith: object.objectID)
  }

  func canDelete(object: NSManagedObject) -> Bool {
    return container.canDeleteRecord(forManagedObjectWith: object.objectID)
  }

    @available(watchOSApplicationExtension 8.0, *)
    func isOwner(object: NSManagedObject) -> Bool {
    guard isShared(object: object) else { return false }
    guard let share = try? container.fetchShares(matching: [object.objectID])[object.objectID] else {
      print("Get ckshare error")
      return false
    }
    if let currentUser = share.currentUserParticipant, currentUser == share.owner {
      return true
    }
    return false
  }

  func getShare(_ child: Child) -> CKShare? {
    guard isShared(object: child) else { return nil }
    guard let shareDictionary = try? container.fetchShares(matching: [child.objectID]),
      let share = shareDictionary[child.objectID] else {
      print("Unable to get CKShare")
      return nil
    }
      share[CKShare.SystemFieldKey.title] = child.name
    return share
  }

  private func isShared(objectID: NSManagedObjectID) -> Bool {
    var isShared = false
    if let persistentStore = objectID.persistentStore {
      if persistentStore == sharedPersistentStore {
        isShared = true
      } else {
        let container = container
        do {
          let shares = try container.fetchShares(matching: [objectID])
          if shares.first != nil {
            isShared = true
          }
        } catch {
          print("Failed to fetch share for \(objectID): \(error)")
        }
      }
    }
    return isShared
  }
}
