//
//  MapOfWorkersCell.swift
//  MyProHelper
//
//  Created by Anupansh on 22/11/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import MapboxMaps

class MapOfWorkersCell: UITableViewCell {

    // MARK: - OUTLETS AND VARIABLES
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var mapBaseView: UIView!
    
    internal var pointAnnotationManager: PointAnnotationManager?
    internal var mapView: MapView!
    internal var cameraLocationConsumer: CameraLocationConsumer!
    var locationData : [String: LocationData]?
    
    // MARK: - CELL LIFECYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        initializeMap()
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        mapView.annotations.removeAnnotationManager(withId: pointAnnotationManager!.id)
        pointAnnotationManager = mapView.annotations.makePointAnnotationManager()

        let currentValue = Float(timeSlider.value)
        print("Current Value",currentValue)
        if let locationData = locationData {
            var pointAnnotation = [PointAnnotation]()
            for thisDevice in locationData {
                let deviceId = thisDevice.value.deviceID
                if let nearestLocations = binarySearch(in: thisDevice.value.locationsThisDeviceID, for: currentValue) {
                    let latitude = nearestLocations.latitude
                    let longitude = nearestLocations.longitude
                    let coordinate = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
                    var customPointAnnotation = PointAnnotation(coordinate: coordinate)
                    customPointAnnotation.image = .init(image: UIImage(named: "pointer")!, name: "pointer")
                    customPointAnnotation.textField = "\(deviceId)"
                    pointAnnotation.append(customPointAnnotation)
                }
            }
            pointAnnotationManager!.annotations = pointAnnotation
        }
    }
    
    func initializeMap() {
        let resourceOptions = ResourceOptions(accessToken: AppLocals.mapBoxKey)
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions,cameraOptions: CameraOptions(zoom: 15))
        mapView = MapView(frame: mapBaseView.bounds, mapInitOptions: mapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        mapBaseView.addSubview(mapView)
        pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        cameraLocationConsumer = CameraLocationConsumer(mapView: mapView)
        mapView.location.options.puckType = .puck2D()
        mapView.mapboxMap.onNext(.mapLoaded) { _ in
            self.mapView.location.addLocationConsumer(newConsumer: self.cameraLocationConsumer)
        }
    }
    
    func updateMap() {
        var minTimeStamp = Float(Int32.max)
        var maxTimeStamp = Float(0)
        var pointAnnotation = [PointAnnotation]()
        if let mapview = mapView {
            if let data = self.locationData {
                for location in data {
                    let locationValue = location.value
                    // Finding max timestamp and min timestamp for slider
                    let startTime = locationValue.locationsThisDeviceID[0].timeStamp
                    let endTime = locationValue.locationsThisDeviceID[locationValue.locationsThisDeviceID.count - 1].timeStamp
                    if startTime < minTimeStamp {
                        minTimeStamp = startTime
                    }
                    if endTime > maxTimeStamp {
                        maxTimeStamp = endTime
                    }
                    // Plotting lat long on map
                    let latitude = locationValue.locationsThisDeviceID.last?.latitude
                    let longitude = locationValue.locationsThisDeviceID.last?.longitude
                    let deviceId = location.value.deviceID
                    if let lat = latitude,let long = longitude {
                        let coordinate = CLLocationCoordinate2D.init(latitude: lat, longitude: long)
                        var customPointAnnotation = PointAnnotation(coordinate: coordinate)
                        customPointAnnotation.image = .init(image: UIImage(named: "pointer")!, name: "pointer")
                        customPointAnnotation.textField = "\(deviceId)"
                        pointAnnotation.append(customPointAnnotation)
                    }
                }
            }
            // Setting slider's intervals
            let min = Float(minTimeStamp)
            let max = Float(maxTimeStamp)
            timeSlider.maximumValue = max
            timeSlider.minimumValue = min
            timeSlider.value = max
            // Plotting Annotations
            pointAnnotationManager!.annotations = pointAnnotation
        }
    }
    
    func binarySearch(in locations1: [LocationsThisDeviceID], for searchTime: Float) -> LocationsThisDeviceID? {
        if locations1.count < 2 {
            return nil // can't search without at least 2 locations
        }
        
        let startTime = Float(locations1[0].timeStamp)
        let stopTime = Float(locations1[locations1.count - 1].timeStamp)
        
        if (searchTime < startTime) || (searchTime > stopTime) {
            return nil // doesn't have the requested time range
        }
        
        var left = 0
        var right = locations1.count - 1

        while left <= right {

            let middle = Int(floor(Double(left + right) / 2.0))

            if Float(locations1[middle].timeStamp) < searchTime {
                left = middle + 1
            } else if Float(locations1[middle].timeStamp) > searchTime {
                right = middle - 1
            } else {
                return locations1[middle] // exact match
            }
        }
        let nearestIndex  = min(left, right)
        return locations1[nearestIndex]
    }
    
}

public class CameraLocationConsumer: LocationConsumer {
    weak var mapView: MapView?
 
    init(mapView: MapView) {
        self.mapView = mapView
    }
 
    public func locationUpdate(newLocation: Location) {
        mapView?.camera.ease(
            to: CameraOptions(center: newLocation.coordinate, zoom: 15),
            duration: 1.3)
    }
}
