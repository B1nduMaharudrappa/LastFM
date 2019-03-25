//
//  CoreDataManager.swift
//  TestTask
//
//  Created by Bindu Maharudrappa on 18.09.18.
//  Copyright © 2018 APPSfactory GmbH. All rights reserved.
//

import UIKit
import CoreData

class DataModel {
    
    static func saveToCoreData(sender: UIButton, array : AlbumDetails) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequests = Album(context: managedContext)
        
        saveToCoredataGraph(fetchRequests: fetchRequests, sender: sender, array : array)
        
    }
    
    static func deleteData(sender: UIButton, array: AlbumDetails) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let deleteObject = array
        
        let predicate = NSPredicate(format: "mbid == %@", deleteObject.mbid!)
        let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
        fetchRequest.predicate = predicate
        if let result = try? managedContext.fetch(fetchRequest) {
            for object in result {
                do{
                    try? managedContext.delete(object)
                }
                catch{
                    
                }
            }
        }
    }
    
    static func saveToCoredataGraph(fetchRequests: Album, sender: UIButton,array : AlbumDetails) {
        
        guard let cell = sender.superview?.superview as? AlbumsTableViewCell else {
            return
        }
        
        if cell.albumImageView != nil {
            let image = cell.albumImageView.image
            let imageData: Data = UIImageJPEGRepresentation(image!, 1)! as Data
            fetchRequests.albumImage = imageData
        }
        
        if let albumName = cell.albumName.text, !albumName.isEmpty {
            fetchRequests.albumName = albumName
        }
        if let artistName = cell.artistName.text, !artistName.isEmpty {
            fetchRequests.artistName = artistName
        }
        fetchRequests.mbid =  array.mbid!
        fetchRequests.isDataSaved = true
        do {
            try  fetchRequests.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print("Unable to Save Note")
            print("\(saveError), \(saveError.localizedDescription)")
        }
        
    }
}
