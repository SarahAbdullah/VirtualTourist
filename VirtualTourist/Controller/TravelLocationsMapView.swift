//
//  TravelLocationsMapView.swift
//  VirtualTourist
//
//  Created by Sarah on 1/25/19.
//  Copyright © 2019 Sarah. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapView: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var longGesture = UILongPressGestureRecognizer()
    var dataController : DataController!
    var fetchResultController : NSFetchedResultsController<Pin>!
    var annotations = [MKPointAnnotation]()
    //MKAnnotation
    var selectedPin : Pin!

    
    func setUpFetchResultsController(){
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescription = NSSortDescriptor(key: "creatDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescription]
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest , managedObjectContext: dataController.viewContext , sectionNameKeyPath: nil , cacheName: "PinCache" )
        fetchResultController.delegate = self
        
        do{
            try fetchResultController.performFetch()
        }catch{
            fatalError("error in fetch \(error.localizedDescription) ")
        }
    }
    
    func setLocationOnTheMap(){
        if let pin = fetchResultController.fetchedObjects?.first{
            zoom(lastLocation: pin)
        }
        
        for location in fetchResultController.fetchedObjects!{
            let annotation = creatAnnotation(latitude: location.latitude , longitude: location.longitude )
            self.annotations.append(annotation)
        }
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotations) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        mapView.addGestureRecognizer(longGesture)
        setUpFetchResultsController()
        setLocationOnTheMap()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpFetchResultsController()
        setLocationOnTheMap()
    
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultController = nil
    }
    
    @objc func longPress(_ sender: UILongPressGestureRecognizer) {

        if sender.state == .began {
            let userLocation = sender.location(in: mapView)
            let mapCoordinate = mapView.convert(userLocation, toCoordinateFrom: mapView)
            //add new Pin
            let pin = Pin(context: dataController.viewContext)
            pin.longitude = mapCoordinate.longitude
            pin.latitude = mapCoordinate.latitude
            pin.creatDate = Date()
            try? dataController.viewContext.save()
        }
    }
    
    func zoom(lastLocation: Pin){
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lastLocation.latitude, lastLocation.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        self.mapView.setRegion(region, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Segue"{
            if let viewController = segue.destination as? PhotoAlbumViewController {
                viewController.dataController = dataController
                viewController.pin = selectedPin

            }
        }
    }
    
    func creatAnnotation(latitude: Double , longitude:Double ) -> MKPointAnnotation{
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }
}

extension TravelLocationsMapView : MKMapViewDelegate  {
    
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let location = view.annotation
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude

        if let pins = fetchResultController.fetchedObjects {
            for pin in pins {
                if pin.longitude == longitude && pin.latitude == latitude {
                    selectedPin = pin
                    performSegue(withIdentifier: "Segue", sender: self)
                }
            }

        }


    }
    
}

extension TravelLocationsMapView : NSFetchedResultsControllerDelegate {

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let pin = anObject as? Pin else {
            return
        }
        let annotation = creatAnnotation(latitude: pin.latitude, longitude: pin.longitude)
        switch type {
        case .insert:
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
            }
        case .delete:
            DispatchQueue.main.async {
                self.mapView.removeAnnotation(annotation)
            }
        default:
            break
        }
    }
}


