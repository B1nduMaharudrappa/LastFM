//
//  ArtistAlbumsViewController.swift
//  TestTask
//
//  Created by Bindu Maharudrappa on 17.09.18.
//  Copyright © 2018 APPSfactory GmbH. All rights reserved.
//

import UIKit
import CoreData

class ArtistAlbumsViewController: BaseViewController {
    var albumsArray = [AlbumDetails]()
    var albumList: Album!
    let appDelegate: AppDelegate =  (UIApplication.shared.delegate as? AppDelegate)!
    var imageArray = [String]()
    var artistName: String?
    @IBOutlet weak var artistAlbumTableview: UITableView! {
        didSet {
            artistAlbumTableview.delegate = self
            artistAlbumTableview.dataSource = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkManager.getArtistAlbumList(artistName: artistName) { artists, error in
            if let albumList = artists?.albumList {
                self.albumsArray = albumList
            }
            for i in 0..<self.albumsArray.count {
                if self.albumsArray[i].image!.item(at: 1)?.imageSize == "medium"{
                    self.imageArray.append((self.albumsArray[i].image?.item(at: 1)?.text)!)
                }
            }
            DispatchQueue.main.async {
                
                guard let appDelegate =
                    UIApplication.shared.delegate as? AppDelegate else {
                        return
                }
                let managedContext = appDelegate.persistentContainer.viewContext
                let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
                if let result = try? managedContext.fetch(fetchRequest) {
                    for object in result {
                        do {
                            for (i, item ) in self.albumsArray.enumerated() {
                                if item.mbid == object.mbid {
                                 var itemToUpdate = self.albumsArray[i]
                                    self.albumsArray.remove(at: i)
                                    itemToUpdate.isAlbumDataSaved = true
                                    self.albumsArray.insert(itemToUpdate, at: i)
                                }
                            }
                        } catch {
                            
                        }
                    }
                }
                self.stopActivityIndicator()
                self.artistAlbumTableview.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.clear], for: .normal)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
    }
    
    @IBAction func favIconClicked(_ sender: UIButton) {
        guard let cell = sender.superview?.superview as? AlbumsTableViewCell else {
            return
        }
        if self.albumsArray[sender.tag].isAlbumDataSaved == false {
            cell.favouriteIconButton.setImage(UIImage(named: "favIconSelected.png"), for: UIControlState.normal)
            self.albumsArray[sender.tag].isAlbumDataSaved = true
            DataModel.saveToCoreData(sender: sender, array: self.albumsArray[sender.tag])
        } else {
            cell.favouriteIconButton.setImage(UIImage(named: "favIcon.png"), for: UIControlState.normal)
            self.albumsArray[sender.tag].isAlbumDataSaved = false
            DataModel.deleteData(sender: sender, array: self.albumsArray[sender.tag])
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ArtistAlbumsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albumDetailVcObj = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlbumDetailViewController") as! AlbumDetailViewController
        albumDetailVcObj.albumName = self.albumsArray[indexPath.row].albumName
        albumDetailVcObj.artistName = self.artistName
        albumDetailVcObj.albumsArray = self.albumsArray
        self.navigationController?.pushViewController(albumDetailVcObj, animated: true)
    }
}

extension ArtistAlbumsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albumsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistAlbumsCell", for: indexPath) as! AlbumsTableViewCell
        cell.artistName.text = self.artistName
        cell.albumName.text = self.albumsArray[indexPath.row].albumName
        cell.albumImageView.loadImage(url: self.imageArray[indexPath.row])
        cell.favouriteIconButton.tag = indexPath.row
        if self.albumsArray[cell.favouriteIconButton.tag].isAlbumDataSaved == false {
            cell.favouriteIconButton.setImage(UIImage(named: "favIcon.png"), for: UIControlState.normal)
        } else {
            cell.favouriteIconButton.setImage(UIImage(named: "favIconSelected.png"), for: UIControlState.normal)
        }
        return cell
    }
}
