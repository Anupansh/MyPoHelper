//
//  CurrentJobsVC.swift
//  MyProHelper
//
//  Created by Anupansh on 21/04/21.
//  Copyright © 2021 Benchmark Computing. All rights reserved.
//

import UIKit
import GRDB
import MapKit

class CurrentJobsVC: UIViewController {
    
    // MARK: - OUTLETS AND VARIABLES
    @IBOutlet weak var customerNameLbl: UILabel!
    @IBOutlet weak var contactNameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var previousVisitBtn: UIButton!
    @IBOutlet weak var nextVisitBtn: UIButton!
    @IBOutlet weak var startJobBtn: UIButton!
    @IBOutlet weak var addNotesBtn: UIButton!
    @IBOutlet weak var revisitBtn: UIButton!
    @IBOutlet weak var invoiceBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var endingSoonBtn: UIButton!
    @IBOutlet weak var endingSoonBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var endingSoonBtnTopConstaint: NSLayoutConstraint!
    @IBOutlet weak var callCustomerBtn: UIButton!
    @IBOutlet weak var goToNextJobBtn: UIButton!
    
    var job = Job()
    var nextJob: Job?
    var locationManager = CLLocationManager()
    var currentLat: Double?
    var currentLong: Double?
    var jobList = [Job]()

    // MARK: - VIEW LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
    // MARK: - HELPER FUNCTIONS
    func initialSetup() {
        title = "Picked Job"
        self.navigationController?.isNavigationBarHidden = false
        let backBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .done, target: self, action: #selector(backBtnPressed))
        self.navigationItem.leftBarButtonItem = backBtn
        statusLbl.cornerRadius = 15.0
        mapView.delegate = self
        self.injectData()
        self.checkLocationAccess()
        self.setupInvoiceButton()     // Don't call setinvoiceButton in inject data. App will crash
    }
    
    func injectData() {
        customerNameLbl.text = "Customer Name: \(job.customer?.customerName ?? "N/A")"
        contactNameLbl.text = "Contact Name: \(job.jobContactPersonName ?? "N/A")"
        dateLbl.text = "Date: \(DateManager.standardDateToStringWithoutHours(date: job.startDateTime))"
        timeLbl.text = "Time: \(DateManager.timeToString(date: job.startDateTime))"
        phoneNumberLbl.text = "Phone number: \(job.jobContactPhone ?? "N/A")"
        addressLbl.text = "Address: \(job.jobLocationAddress1 ?? "N/A")"
        descriptionLbl.text =  "Description: \(job.jobDescription ?? "N/A")"
        statusLbl.text = "\(job.jobStatus ?? "N/A")"
        setupActionButtons()
        setupVisitButtons()
        setupGoToNextJobButton()
    }
    
    func jumpToCreateInvoice(invoice: Invoice,isEditingEnabled: Bool) {
        let createInvoiceView = CreateInvoiceView.instantiate(storyboard: .INVOICE)
        createInvoiceView.cameFromCurrentJobs = true
        createInvoiceView.viewModel = CreateInvoiceViewModel(attachmentSource: .INVOICE)
        createInvoiceView.setViewMode(isEditingEnabled: isEditingEnabled)
        createInvoiceView.viewModel.setInvoice(invoice: invoice)
        navigationController?.pushViewController(createInvoiceView, animated: true)
    }
    
    // MARK: - IBACTIONS
    @objc func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func previousVisitBtnPressed(_ sender: Any) {
        self.fetchJob(jobID: job.previousVisitJobId!)
        self.updateLocation()
        setupInvoiceButton()
        guard let jobIndex = jobList.firstIndex(where: {$0.jobID == self.job.jobID}) else {return}
        if jobList.indices.contains(jobIndex + 1) {
            nextJob = jobList[jobIndex + 1]
        }
    }
    
    @IBAction func nextVisitBtnPressed(_ sender: Any) {
        self.fetchJob(jobID: job.nextVisitJobId!)
        self.updateLocation()
        setupInvoiceButton()
        guard let jobIndex = jobList.firstIndex(where: {$0.jobID == self.job.jobID}) else {return}
        if jobList.indices.contains(jobIndex + 1) {
            nextJob = jobList[jobIndex + 1]
        }
    }
    
    @IBAction func startJobBtnPressed(_ sender: Any) {
        if job.jobStatus == "Scheduled" || job.jobStatus == "Waiting" {
            DBHelper.updateJobStatus(status: .inProgress, jobID: job.jobID!) {
                self.statusLbl.text = "In Progress"
                self.job.jobStatus = "In Progress"
                self.startJobBtn.setTitle("End Job", for: .normal)
                self.startJobBtn.backgroundColor = .link
                self.endingSoonBtnHeightConstraint.constant = 40
                self.endingSoonBtnTopConstaint.constant = 20
                self.endingSoonBtn.isHidden = false
                return nil
            }
        }
        else if job.jobStatus == "In Progress" || job.jobStatus == "Invoiced" || job.jobStatus == "Rejected" {
            DBHelper.updateJobStatus(status: .completed, jobID: job.jobID!) {
                self.statusLbl.text = "Completed"
                self.job.jobStatus = "Completed"
                self.startJobBtn.setTitle("Job Completed", for: .normal)
                self.startJobBtn.backgroundColor = .darkGray
                self.startJobBtn.isEnabled = false
                self.endingSoonBtnHeightConstraint.constant = 0
                self.endingSoonBtnTopConstaint.constant = 0
                self.endingSoonBtn.isHidden = true
                return nil
            }
        }
    }
    
    @IBAction func endingSoonBtnPressed(_ sender: Any) {
        if let _ = nextJob {
            estimateTimeToReachNextCustomer { [weak self] (time) in
                let intMinutes = Int(time)
                let alert = UIAlertController(title: "Time to reach next job is \(intMinutes) minutes", message: "Enter extra time in minutes to reach", preferredStyle: .alert)
                alert.addTextField { (textfeild) in
                    textfeild.placeholder = "Enter time"
                    textfeild.keyboardType = .numberPad
                }
                let sendAction = UIAlertAction(title: "Send", style: .default) { (alertAction) in
                    guard let tf = alert.textFields?.first else {return}
                    let time = tf.text
                    // Send this
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(sendAction)
                alert.addAction(cancelAction)
                self?.present(alert, animated: true, completion: nil)
            }
        }
        else {
            CommonController.shared.showSnackBar(message: Constants.Message.NO_NEXT_JOB, view: self)
        }
    }
    
    @IBAction func addNotesBtnPressed(_ sender: Any) {
        let vc = AppStoryboards.home.instantiateViewController(withIdentifier: HomeAddNotesVC.className) as! HomeAddNotesVC
        vc.jobId = self.job.jobID
        vc.customerId = self.job.customerID
        vc.customerName = self.job.jobContactPersonName
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func revisitBtnPressed(_ sender: Any) {
        let vc = AppStoryboards.home.instantiateViewController(withIdentifier: RevisitJobVC.className) as! RevisitJobVC
        vc.job = self.job
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func invoiceBtnPressed(_ sender: Any) {
        DBHelper.getInvoicesForJob(id: job.jobID!) { (invoices) in
            if invoices.isEmpty {
                let createInvoiceView = CreateInvoiceView.instantiate(storyboard: .INVOICE)
                createInvoiceView.cameFromCurrentJobs = true
                createInvoiceView.viewModel = CreateInvoiceViewModel(attachmentSource: .INVOICE)
                createInvoiceView.viewModel.invoice.value.jobID = job.jobID
                createInvoiceView.viewModel.invoice.value.customer = job.customer
                createInvoiceView.viewModel.invoice.value.job = job
                createInvoiceView.setViewMode(isEditingEnabled: true)
//                        createInvoiceView.shareInvoiceClosure = { [weak self] in
//                            self?.statusLbl.text = "Invoiced"
//                            self?.delegate?.updateJobStatus(jobStatus: "Invoiced")
//                        }
                navigationController?.pushViewController(createInvoiceView, animated: true)
            }
            else {
                if let isInvoiceFinal = invoices.last!.isInvoiceFinal {
                    if isInvoiceFinal {
                        self.jumpToCreateInvoice(invoice: invoices.last!, isEditingEnabled: false)
                    }
                    else {
                        self.jumpToCreateInvoice(invoice: invoices.last!, isEditingEnabled: true)
                    }
                }
                else {
                    self.jumpToCreateInvoice(invoice: invoices.last!, isEditingEnabled: true)
                }
            }
            return nil
        }
    }
    
    @IBAction func callCustomerBtnPressed(_ sender: Any) {
        if let phone = job.jobContactPhone {
            if let url = URL(string: "tel://\(phone)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil) }
        }
        else {
            GlobalFunction.showMessageAlert(fromView: self, title: AppLocals.appName, message: Constants.Message.MOBILE_NOT_AVAILABLE)
        }
    }
    
    @IBAction func goToNextJobBtnPressed(_ sender: Any) {
        let jobIndex = jobList.firstIndex(where: {$0.jobID == self.job.jobID})
        guard let nextJobId = jobList[jobIndex! + 1].jobID else {return}
        self.fetchJob(jobID: Int64(nextJobId))
        self.updateLocation()
        if jobList.indices.contains(jobIndex! + 1) {
            nextJob = jobList[jobIndex! + 1]
        }
        setupInvoiceButton()
    }
    
    @IBAction func openAppleMaps(_ sender: Any) {
        self.getDestinationLatLong { (lat, long) in
            let query = "?daddr=\(lat),\(long)"
                  let path = "http://maps.apple.com/" + query
                  if let url = NSURL(string: path) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                  } else {
                    // Could not construct url. Handle error.
                  }
            return nil
        }
    }
    
    // MARK: - SETUP ACTION BUTTONS
    func setupVisitButtons() {
        if job.previousVisitJobId == 0 || job.previousVisitJobId == nil {
            previousVisitBtn.setTitleColor(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1), for: .normal)
            previousVisitBtn.borderColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            previousVisitBtn.isUserInteractionEnabled = false
        }
        else {
            previousVisitBtn.setTitleColor(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), for: .normal)
            previousVisitBtn.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            previousVisitBtn.isUserInteractionEnabled = true
        }
        if job.nextVisitJobId == 0  || job.nextVisitJobId == nil {
            nextVisitBtn.setTitleColor(#colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1), for: .normal)
            nextVisitBtn.borderColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            nextVisitBtn.isUserInteractionEnabled = false
        }
        else {
            nextVisitBtn.setTitleColor(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), for: .normal)
            nextVisitBtn.borderColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            nextVisitBtn.isUserInteractionEnabled = true
        }
    }
    
    func setupActionButtons() {
        
        // Setup Start Job Button
        if job.jobStatus == "Scheduled" || job.jobStatus == "Waiting" {
            startJobBtn.setTitle("Start Job", for: .normal)
            startJobBtn.backgroundColor = .link
            startJobBtn.isEnabled = true
            endingSoonBtnTopConstaint.constant = 0
            endingSoonBtnHeightConstraint.constant = 0
            endingSoonBtn.isHidden = true
        }
        else if job.jobStatus == "In Progress" {
            startJobBtn.setTitle("End Job", for: .normal)
            startJobBtn.backgroundColor = .link
            startJobBtn.isEnabled = true
            endingSoonBtnTopConstaint.constant = 20
            endingSoonBtnHeightConstraint.constant = 40
            endingSoonBtn.isHidden = false
        }
        else if job.jobStatus == "Completed" || job.jobStatus == "Invoiced" || job.jobStatus == "Rejected"  {
            startJobBtn.setTitle("Job Completed", for: .normal)
            startJobBtn.backgroundColor = .darkGray
            startJobBtn.isEnabled = false
            endingSoonBtnTopConstaint.constant = 0
            endingSoonBtnHeightConstraint.constant = 0
            endingSoonBtn.isHidden = true
        }
    }
    
    func setupInvoiceButton() {
        DBHelper.getInvoicesForJob(id: job.jobID!) { (invoices) in
            if invoices.isEmpty {
                invoiceBtn.setTitle("Create Invoice", for: .normal)
            }
            else {
                if let isInvoiceFinal = invoices.last!.isInvoiceFinal {
                    if isInvoiceFinal {
                        invoiceBtn.setTitle("View Invoice", for: .normal)
                    }
                    else {
                        invoiceBtn.setTitle("Adjust Invoice", for: .normal)
                    }
                }
                else {
                    invoiceBtn.setTitle("Adjust Invoice", for: .normal)
                }
            }
            return nil
        }
    }
    
    func setupGoToNextJobButton() {
        guard let jobIndex = jobList.firstIndex(where: {$0.jobID == self.job.jobID}) else {
            goToNextJobBtn.isHidden = true
            return
        }
        if jobList.indices.contains(jobIndex + 1) {
            goToNextJobBtn.isHidden = false
        }
        else {
            goToNextJobBtn.isHidden = true
        }
    }
    
    // MARK: FETCH JOB WITH JOBID
    func fetchJob(jobID: Int64) {
        guard let queue = AppDatabase.shared.attachDababaseQueue else {return}
        var sql = """
            Select * from main.\(RepositoryConstants.Tables.SCHEDULED_JOBS)
            LEFT JOIN main.\(RepositoryConstants.Tables.CUSTOMERS) ON main.\(RepositoryConstants.Tables.SCHEDULED_JOBS).\(RepositoryConstants.Columns.CUSTOMER_ID) =
                    main.\(RepositoryConstants.Tables.CUSTOMERS).\(RepositoryConstants.Columns.CUSTOMER_ID)
            LEFT JOIN main.\(RepositoryConstants.Tables.WORKERS) ON main.\(RepositoryConstants.Tables.SCHEDULED_JOBS).\(RepositoryConstants.Columns.WORKER_SCHEDULED) =
                    main.\(RepositoryConstants.Tables.WORKERS).\(RepositoryConstants.Columns.WORKER_ID)
            WHERE main.\(RepositoryConstants.Tables.SCHEDULED_JOBS).\(RepositoryConstants.Columns.JOB_ID) = \(jobID)
        """
        let chgSql = " union \(sql.replaceMain())"
        sql += chgSql
        do {
            try queue.read { (database) in
                let rows = try Row.fetchCursor(database, sql: sql)
                while let row = try rows.next() {
                    let singleJob = Job.init(row: row)
                    self.job = singleJob
                    self.injectData()
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - CHECK LOCATION ACCESS
    func checkLocationAccess() {
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //MARK: - GET LAT LONG FROM ADDRESS
    func getDestinationLatLong(completionHandler: @escaping ((CLLocationDegrees,CLLocationDegrees) -> ()?)) {
        let destinationAddress = job.jobLocationAddress1
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(destinationAddress!) { (placemarks, error) in
            guard let placemarks = placemarks,let location = placemarks.first?.location else {
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.removeOverlays(self.mapView.overlays)
                return
            }
            completionHandler(location.coordinate.latitude,location.coordinate.longitude)
        }
    }
    
    //MARK: - PLOT ROUTE ON MAP
    func plotRouteOnMap(sourceLocation: CLLocationCoordinate2D,destinationLocation: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Current Location"
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        let destinationAnnotation = MKPointAnnotation()
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true)

        //Plotting a course from Source to Destination
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile

        //Calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) -> Void in
            guard let response = response else { return}
            let route = response.routes[0]
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    //MARK: - UPDATE LOCATIONS ON MAP
    func updateLocation() {
        guard let sourceLocation: CLLocationCoordinate2D = locationManager.location?.coordinate else {return}
        self.getDestinationLatLong() { [weak self] (destLat, destLong) in
            let destinationLocation = CLLocationCoordinate2D.init(latitude: destLat, longitude: destLong)
            self?.plotRouteOnMap(sourceLocation: sourceLocation, destinationLocation: destinationLocation)
            return nil
        }
    }
    
    func estimateTimeToReachNextCustomer(completionHandler:  @escaping (Double) -> ()) {
        guard let nextJob = nextJob else {return}
        var travelTime = 20.0
        let destinationAddress = nextJob.jobLocationAddress1
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(destinationAddress!) { (placemarks, error) in
            guard let placemarks = placemarks,let location = placemarks.first?.location else {return}
            let sourceLocation = CLLocationCoordinate2D(latitude: self.currentLat ?? 0.0, longitude: self.currentLong ?? 0.0)
            let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            
            //Obtaining a course from Source to Destination
            let directionRequest = MKDirections.Request()
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationMapItem
            directionRequest.transportType = .automobile
            
            //Calculate the time
            let directions = MKDirections(request: directionRequest)
            directions.calculate { (response, error) -> Void in
                if let _ = error {
                    completionHandler(20)
                }
                else {
                    guard let response = response else { return}
                    let route = response.routes[0]
                    travelTime = route.expectedTravelTime
                    completionHandler(travelTime)
                }
            }
        }
    }
    
}

//MARK: - LOCATION MANAGER AND MAPVIEW DELEGATES
extension CurrentJobsVC: CLLocationManagerDelegate, MKMapViewDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways,.authorizedWhenInUse:
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        default:
            CommonController.shared.showSnackBar(message: Constants.Message.ALLOW_LOCATION, view: self)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation: CLLocationCoordinate2D = manager.location?.coordinate else {return}
        self.currentLat = currentLocation.latitude
        self.currentLong = currentLocation.longitude
        self.getDestinationLatLong() { [weak self] (destLat, destLong) in
            let destinationLocation = CLLocationCoordinate2D.init(latitude: destLat, longitude: destLong)
            self?.plotRouteOnMap(sourceLocation: currentLocation, destinationLocation: destinationLocation)
            
            // If distance is less than 50 metres remove this job from list
            let clLocationSource = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            let clLocationDest = CLLocation(latitude: destLat, longitude: destLong)
            let distance = clLocationDest.distance(from: clLocationSource)
            if distance < 50 {
                AppLocals.pickedJob = self!.job
            }
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        renderer.lineWidth = 5.0
        return renderer
    }
}

