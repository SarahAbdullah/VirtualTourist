//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Sarah on 1/26/19.
//  Copyright © 2019 Sarah. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Foundation

class PhotoAlbumViewController: UIViewController  {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImageLable: UILabel!
    @IBOutlet weak var newCollection: UIButton!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pin : Pin!
    var dataController : DataController!
    var fetchResultController : NSFetchedResultsController<Photo>!
    
    var photosURL = [URL]()
    var BOperations: [BlockOperation] = []
    var deletedPhoto = [IndexPath]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFetchResultsController()
        let isNewFetch = self.fetchResultController.fetchedObjects
        if isNewFetch?.count == 0 {
            getPhotos()
        }
        setFlowLayout()
        setLocationOnTheMap()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultController = nil
    }
    
    
    func setUpFetchResultsController(){
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.predicate = predicate
        let sortDescription = NSSortDescriptor(key: "creatDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescription]
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest , managedObjectContext: dataController.viewContext , sectionNameKeyPath: nil , cacheName: nil )
        fetchResultController.delegate = self
        
        do{
            try fetchResultController.performFetch()
        }catch{
            fatalError("error in fetch \(error.localizedDescription) ")
        }
    }
    
    
    func setLocationOnTheMap(){
        
        let annotation = MKPointAnnotation()
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotation.coordinate = coordinate
        
        let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        DispatchQueue.main.async {
            self.mapView.addAnnotation(annotation)
            self.mapView.setRegion(region, animated: true) }
    }
    
    
    func getPhotos(){
        //1- get total Pages
        FlickrClient.sharedInstance.getTotalPages(longitude: pin.longitude, latitude: pin.latitude){ (success, assignTotal, errorMessage) in
            if !assignTotal{
                FlickrClient.sharedInstance.totalPages = 1
            }

        }
        
        
        //1- get photos by page number
        FlickrClient.sharedInstance.searchPhotos(longitude: pin.longitude, latitude: pin.latitude ){ (success,Empty, photos ,  errorMessage) in

            if success {
                if (Empty){
                    DispatchQueue.main.async {
                        self.noImageLable.text = "No Images"
                        self.noImageLable.isHidden = false
                        
                    }
                }else{
                    DispatchQueue.main.async {
                        self.noImageLable.isHidden = true }
                    if let photos = photos {
                        for photo in photos {
                            if let stringUrl = photo["url_m"] {
                                let url = URL(string: stringUrl as! String)
                                self.photosURL.append(url!)
                            }
                        }
                        self.downloadPhotos()
                    }
                    
                }
            }

        }
        
        
    }
    
    // save photo to the core data
    func downloadPhotos(){
        
        if (fetchResultController.fetchedObjects?.isEmpty)! {
            for url in photosURL {
                let task = URLSession.shared.dataTask(with: url) { (data ,response, error) in
                    if error == nil {
                        if let data = data {
                            let photo = Photo(context: self.dataController.viewContext)
                            photo.binaryPhoto = data
                            photo.creatDate = Date()
                            photo.pin = self.pin
                            try? self.dataController.viewContext.save()
                            
                        } }
                }
                task.resume()
                
            }
            
        }
        
    }
    
    func setFlowLayout(){
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    
    @IBAction func newCollection(_ sender: Any) {
        
        let button = sender as! UIButton
        
        if button.currentTitle == "New Collection" {
            
            guard let result = self.fetchResultController.fetchedObjects else{return}
            
            for photo in result {
                dataController.viewContext.delete(photo)
                try? dataController.viewContext.save()
            }
            photosURL.removeAll()
            self.getPhotos()
            
            
        }else if button.currentTitle == "Remove" {
            
            newCollection.setTitle("New Collection", for: .normal)
            deletePhotos()
            
        }
        
        
        
    }
    
    func deletePhotos(){
        for indexPath in deletedPhoto {
            let photo = fetchResultController.object(at:indexPath) as Photo
            dataController.viewContext.delete(photo)
            try? dataController.viewContext.save()
        }
        deletedPhoto.removeAll()
    }
    
    
    deinit {
        for operation in BOperations {
            operation.cancel() }
        BOperations.removeAll(keepingCapacity: false)
    }
    
    
    
}


extension PhotoAlbumViewController : MKMapViewDelegate  {
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}


extension PhotoAlbumViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "Cell" , for: indexPath) as! PhotoCell
        DispatchQueue.main.async{
            cell.SelectedCell.isHidden = true
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating() }
        
        let Photos = self.fetchResultController.fetchedObjects!
        cell.imageView.image = UIImage(data: Photos[indexPath.row].binaryPhoto!)
        
        DispatchQueue.main.async{
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
            self.newCollection.isEnabled = true }
        
        return cell
        
    }
    
    
}


extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell =  collectionView.cellForItem(at: indexPath) as! PhotoCell
        
        cell.SelectedCell.isHidden = false
        newCollection.setTitle("Remove" , for: .normal)
        deletedPhoto.append(indexPath)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell =  collectionView.cellForItem(at: indexPath) as! PhotoCell
        cell.SelectedCell.isHidden = true
        deletedPhoto.remove(at: indexPath.startIndex)
        
        if deletedPhoto.isEmpty{
            newCollection.setTitle("New Collection" , for: .normal)
        }
    }
}

extension PhotoAlbumViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        BOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        let operation : BlockOperation
        switch type {
            
        case .insert:
            if let index = newIndexPath {
                operation = BlockOperation { self.collectionView.insertItems(at: [index]) }
                BOperations.append(operation)
            }
        case .update:
            if let index = indexPath {
                operation = BlockOperation {
                    self.collectionView.reloadItems(at: [index] ) }
                BOperations.append(operation)
            }
        case .move:
            if let index = indexPath , let newIndex = newIndexPath {
                operation = BlockOperation {
                    self.collectionView.moveItem(at: index, to: newIndex) }
                BOperations.append(operation)
            }
        case .delete:
            if let index = indexPath {
                operation = BlockOperation {
                    self.collectionView.deleteItems(at: [index]) }
                BOperations.append(operation)
            }
        }
        
        
        
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView!.performBatchUpdates({
            self.BOperations.forEach {
                $0.start()
            }
        }, completion: { finished in
            self.BOperations.removeAll(keepingCapacity: false)
        })
    }
    
}




