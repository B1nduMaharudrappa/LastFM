//
//  AlbumDetailViewController.swift
//  TestTask
//
//  Created by Bindu on 18.09.18.
//  Copyright © 2018 APPSfactory GmbH. All rights reserved.
//

import UIKit
import CoreData

class AlbumDetailViewController: BaseViewController {

    @IBOutlet weak var albumImage: UIImageView!
    var albumsArray = [AlbumDetails]()
    @IBOutlet weak var favAlbumIconButton: UIButton!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    @IBOutlet weak var trackListTableView: UITableView! {
        didSet {
            self.trackListTableView.delegate = self
            self.trackListTableView.dataSource = self
        }
    }
    @IBOutlet weak var albumNameLabel: UILabel!
    var artistName: String?
    var albumName: String?
    
    var imageArray = [AlbumImage]()
    var trackListArray = [Tracks]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.getAlbumDetails(artistName: artistName, albumName: albumName) { albums, error in
            DispatchQueue.main.async {
                if let albumName = albums?.albumName {
                    self.albumNameLabel.text = "Album Name: "+albumName
                }
                if let artistName = albums?.artistName {
                    self.artistNameLabel.text = "Artist Name: "+artistName
                }
                if let image = albums?.albumImage {
                    self.imageArray = image
                    if self.imageArray[1].imageSize == "medium" {
                        print(self.imageArray[1].text as Any)
                        self.albumImage.loadImage(url: self.imageArray[1].text!)
                    }
                }
                guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                        return
                }
                let managedContext = appDelegate.persistentContainer.viewContext
                let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
                if let result = try? managedContext.fetch(fetchRequest) {
                    for object in result {
                        do {
                            if object.isDataSaved == true {
                                self.favAlbumIconButton.setImage(UIImage(named: "favIconSelected.png"), for: UIControlState.normal)
                            } else {
                                self.favAlbumIconButton.setImage(UIImage(named: "favIcon.png"), for: UIControlState.normal)
                            }
                        } catch {
                            
                        }
                    }
                }
                if let tracks = albums?.tracksList?.tracks {
                    self.trackListArray = tracks
                    self.trackListTableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.clear], for: .normal)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    @IBAction func favIconButtonClicked(_ sender: UIButton) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
        if let result = try? managedContext.fetch(fetchRequest) {
            for object in result {
                do {
                    if object.isDataSaved == true {
                        self.favAlbumIconButton.setImage(UIImage(named: "favIcon.png"), for: UIControlState.normal)
                        DataModel.deleteData(sender: sender, array: self.albumsArray[sender.tag])
                        object.isDataSaved = false
                    }
                    else {
                        self.favAlbumIconButton.setImage(UIImage(named: "favIconSelected.png"), for: UIControlState.normal)
                        DataModel.saveToCoreData(sender: sender, array: self.albumsArray[sender.tag])
                        object.isDataSaved = true
                    }
                } catch {
                    
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AlbumDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.trackListArray.count > 0 {
            return "Tracks List:"
        }
        return ""
    }
}

extension AlbumDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trackListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = self.trackListArray[indexPath.row].trackName
        return cell
    }
    
    
}
