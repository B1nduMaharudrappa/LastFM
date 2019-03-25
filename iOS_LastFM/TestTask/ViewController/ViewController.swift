//
//  Created by APPSfactory GmbH
//  Copyright © 2017 APPSfactory GmbH. All rights reserved.
//

import UIKit
import CoreData

class ViewController: BaseViewController {

    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var listTopConstraint: NSLayoutConstraint!
    var jsonData: Data!
    var artistArray = [ArtistDetails]()
    let appDelegate: AppDelegate =  (UIApplication.shared.delegate as? AppDelegate)!
    var albumList = [Album]()
    @IBOutlet weak var searchBarArtist: UISearchBar! {
        didSet {
            searchBarArtist.delegate = self
        }
    }
    
    private let sectionInsets = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
    
    @IBOutlet weak var artistListTableView: UITableView!
    
    @IBOutlet weak var favAlbumsCollectionView: UICollectionView! {
        didSet {
            self.favAlbumsCollectionView.delegate = self
            self.favAlbumsCollectionView.dataSource = self
        }
    }
    override func viewDidLoad() {
		super.viewDidLoad()
       // _ = self.fetchAlbum()
	}
    
    override func viewWillAppear(_ animated: Bool) {
        let barButtonItemAppearance = UIBarButtonItem.appearance()
        barButtonItemAppearance.setTitleTextAttributes([kCTForegroundColorAttributeName as NSAttributedStringKey: UIColor.clear], for: .normal)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.searchBarArtist.isHidden = true
        _ = self.fetchAlbum()
        if self.albumList.count > 0 {
            self.artistListTableView.isHidden = true
            self.favAlbumsCollectionView.isHidden = false
            collectionViewTopConstraint.constant = -55
            self.favAlbumsCollectionView.reloadData()
        }
        DispatchQueue.main.async {
            self.artistArray.removeAll()
            self.artistListTableView.reloadData()
        }
    }
    
    @IBAction func searchIconClicked(_ sender: UISearchBar) {
        self.searchBarArtist.isHidden = false
        self.artistListTableView.isHidden = false
        self.favAlbumsCollectionView.isHidden = true
        self.searchBarArtist.resignFirstResponder()
    }
    
    func fetchAlbum() -> NSFetchRequest<Album> {
        let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let managedContext = appDelegate.persistentContainer.viewContext
            let result = try managedContext.fetch(fetchRequest)
            for _ in result as [NSManagedObject] {
                self.albumList = result
            }
            
        } catch {
            
            print("Failed")
        }
        
        return fetchRequest
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text
            else {
                return
        }
        NetworkManager.getArtistNameList(artistName: text) { artists, error in
            if let artistName =  artists?.artistMatches?.artists {
                self.artistArray = artistName
            }
            DispatchQueue.main.async {
                self.stopActivityIndicator()
                self.artistListTableView.isHidden = false
                self.searchBarArtist.resignFirstResponder()
                self.artistListTableView.reloadData()
            }
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarArtist.isHidden = true
        if self.albumList.count > 0 {
            self.artistListTableView.isHidden = true
            self.favAlbumsCollectionView.isHidden = false
            collectionViewTopConstraint.constant = -55
        } else {
            
        }
        searchBar.text = ""
        searchBarArtist.resignFirstResponder()
        self.artistArray.removeAll()
        DispatchQueue.main.async {
            self.artistListTableView.reloadData()
        }
    }
    func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
    
    }
}

extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {

    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let artistAlbumVcObj = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ArtistAlbumsViewController") as! ArtistAlbumsViewController
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        artistAlbumVcObj.artistName = currentCell.textLabel?.text
        self.navigationController?.pushViewController(artistAlbumVcObj, animated: true)

    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.artistArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistListCell", for: indexPath)
        cell.textLabel?.text =  self.artistArray[indexPath.row].artistName
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let albumDetailVcObj = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AlbumDetailViewController") as! AlbumDetailViewController
        albumDetailVcObj.artistName = self.albumList[indexPath.row].artistName
        albumDetailVcObj.albumName = self.albumList[indexPath.row].albumName
        self.navigationController?.pushViewController(albumDetailVcObj, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.albumList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favAlbumCell", for: indexPath as IndexPath) as! FavAlbumsCollectionViewCell
        if self.albumList[indexPath.row].albumName != nil {
            cell.albumName.text = self.albumList[indexPath.row].albumName
        }
        if self.albumList[indexPath.row].artistName != nil {
            cell.artistName.text = self.albumList[indexPath.row].artistName
        }
        if self.albumList[indexPath.row].albumImage != nil {
           cell.albumImageView.image = UIImage(data: self.albumList[indexPath.row].albumImage!)
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return self.sectionInsets
    }
    
    // This method controls the spacing between each line in the layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left + 5
    }
}
