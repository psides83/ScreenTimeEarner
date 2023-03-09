//
//  SceneDelegate.swift
//  SimpleGoceryList
//
//  Created by Payton Sides on 6/20/21.
//

import SwiftUI
import UIKit
import CloudKit

class SceneDelegate: NSObject, UIWindowSceneDelegate {
//    handle accepting a share
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        let shareStore = PersistenceController.shared.sharedPersistentStore
        let persistentContainer = PersistenceController.shared.container
        persistentContainer.acceptShareInvitations(from: [cloudKitShareMetadata], into: shareStore) { _, error in
          if let error = error {
            print("acceptShareInvitation error :\(error)")
          }
        }
    }
}
