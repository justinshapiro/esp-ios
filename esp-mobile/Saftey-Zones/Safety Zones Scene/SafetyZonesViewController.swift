//
//  SafetyZonesViewController.swift
//  esp-mobile
//
//  Created by Justin Shapiro on 10/27/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import MapKit
import UIKit

final class SafetyZonesViewController: UIViewController {

    // MARK: View Model
    
    enum ViewModel {
        case preInitial(PreInitial)
        case initial(Initial)
        case waiting
        case waitingWithFunctionality
        case success
        case failure(Failure)
        
        struct PreInitial {
            let invokeGetLocation: (String, @escaping (Location?) -> Void) -> Void
            let invokeReadyForUpdate: () -> Void
        }
        
        struct Initial {
            let userLocation: CLLocation
            let locations: [Location]
        }
        
        struct Failure {
            let message: String
        }
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak private var milesLabel: UILabel! {
        didSet {
            milesLabel.text = "5 mi"
        }
    }
    
    @IBOutlet weak private var radiusSlider: UISlider! {
        didSet {
            radiusSlider.isEnabled = false
        }
    }
    
    @IBAction private func sliderChanged(_ sender: UISlider) {
        if radiusSlider.isEnabled {
            let miles = Int(sender.value)
            milesLabel.text = "\(miles) mi"
        
            setRegion(from: miles, with: userLocation!)
        }
    }
    
    @IBOutlet weak private var errorView: UIView!
    @IBOutlet weak private var errorMessage: UILabel!
    @IBOutlet weak private var effectiveErrorView: UIView! {
        didSet {
            effectiveErrorView.layer.cornerRadius = 5
            effectiveErrorView.layer.shadowColor = UIColor.black.cgColor
            effectiveErrorView.layer.shadowOpacity = 0.5
            effectiveErrorView.layer.shadowRadius = 1
            effectiveErrorView.layer.shadowOffset = CGSize(width: 3, height: 3)
        }
    }
    
    @IBOutlet weak var waitingIndicator: UIActivityIndicatorView! {
        didSet {
            waitingIndicator.stopAnimating()
            waitingIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
    }
    
    @IBAction private func errorDismiss(_ sender: UIButton) {
        errorView.isHidden = true
    }
    
    @IBOutlet private var filters: [UIButton]! {
        didSet {
            filters.forEach {
                $0.layer.cornerRadius = 5
                $0.backgroundColor = .espOrange
                $0.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
                $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
                $0.layer.shadowOpacity = 1.0
                $0.layer.shadowRadius = 0.0
                $0.layer.masksToBounds = false
            }
        }
    }
    
    @IBOutlet weak private var filterView: UIView! {
        didSet {
            filterView.layer.cornerRadius = 3
            filterView.layer.borderColor = UIColor.black.cgColor
            filterView.layer.borderWidth = 1
            filterView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            filterView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            filterView.layer.shadowOpacity = 1.0
            filterView.layer.shadowRadius = 0.0
            filterView.layer.masksToBounds = false
        }
    }
    
    @IBOutlet weak private var enableFiltersButton: UIButton! {
        didSet {
            enableFiltersButton.layer.cornerRadius = 5
        }
    }
    
    @IBAction private func enableFilters(_ sender: UIButton) {
        if filtersShowing {
            enableFiltersButton.setImage(UIImage(named: "filter_black_filled"), for: .normal)
            UIView.animate(withDuration: 0.3, animations: {
                self.filterView.frame = CGRect(
                    x: 1.5 * self.filterView.frame.width,
                    y: self.filterView.frame.minY,
                    width: self.filterView.frame.width,
                    height: self.filterView.frame.height
                )
            })
        } else {
            enableFiltersButton.setImage(UIImage(named: "filter_black_filled_highlighted"), for: .normal)
            UIView.animate(withDuration: 0.3, animations: {
                self.filterView.frame = CGRect(
                    x: 0,
                    y: self.filterView.frame.minY,
                    width: self.filterView.frame.width,
                    height: self.filterView.frame.height
                )
            })
        }
        
        filtersShowing = !filtersShowing
    }
    
    @IBAction private func filterStateChanged(_ sender: UIButton) {
        var mode: Bool
        if (sender.backgroundColor == .espOrange) {
            sender.backgroundColor = UIColor.white
            sender.setTitleColor(UIColor.lightGray, for: .normal)
            
            mode = true
        } else {
            sender.backgroundColor = .espOrange
            sender.setTitleColor(UIColor.black, for: .normal)
            
            mode = false
        }
        
        displayedPins.forEach {
            switch (sender.tag) {
            case 0: $0.1 == "hospital"     ? mapView.view(for: $0.0)?.isHidden = mode : nil
            case 1: $0.1 == "police"       ? mapView.view(for: $0.0)?.isHidden = mode : nil
            case 2: $0.1 == "fire_station" ? mapView.view(for: $0.0)?.isHidden = mode : nil
            case 3: $0.1 == "custom"       ? mapView.view(for: $0.0)?.isHidden = mode : nil
            default: break
            }
        }
    }
    
    @IBOutlet private var menuButton: UIBarButtonItem!
    @IBAction func unwindFromFeedback(segue: UIStoryboardSegue) {}
    @IBOutlet weak private var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    @IBOutlet var distressExitButton: UIBarButtonItem!
    @IBAction func exitDistressMode(_ sender: UIBarButtonItem) {
        UserDefaults.standard.set(false, forKey: "distressMode")
        performSegue(withIdentifier: "logOut", sender: self)
    }
    
    @IBOutlet weak var distressModeLabel: UILabel!
    
    // MARK: Properties
    
    private var locationToSend: Location?
    private var filtersShowing = false
    private var invokeGetLocation: ((String, @escaping (Location?) -> Void) -> Void)?
    private var invokeReadyForUpdate: (() -> Void)?
    private var userLocation: CLLocation?
    private var displayedPins: [(SafetyZoneAnnotation, String)] = []
    
    // MARK: Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        Timer(
            timeInterval: 60,
            target: self,
            selector: #selector(checkForSafetyZoneProximity),
            userInfo: nil,
            repeats: true
            ).fire()
        
        // prevents going back with swipe gestures throughout the app, since this is the root of the navigation hierarchy
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let shouldUpdateMap = UserDefaults.standard.object(forKey: "shouldUpdateMap") as? Bool {
            if shouldUpdateMap == true {
                resetFilters()
                UserDefaults.standard.set(false, forKey: "shouldUpdateMap")
                UserDefaults.standard.synchronize()
                displayedPins = []
                mapView.removeAnnotations(mapView.annotations)
                invokeReadyForUpdate?()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationDetail" && locationToSend != nil {
            let viewController = segue.destination as? LocationDetailViewController
            viewController?.locationFromMap = locationToSend!
        }
    }
    
    // MARK: Helper methods
    
    @objc private func detailButtonClicked(_ sender: AnyObject) {
        waitingIndicator.startAnimating()
        performSegue(withIdentifier: "locationDetail", sender: self)
    }
    
    @objc private func callPhoneNumber(sender: UIButton) {
        guard let safetyZoneAnnotationView = sender.superview as? SafetyZoneAnnotationView else { return }
        let callablePhoneNumber = Location.getCallable(phoneNumber: safetyZoneAnnotationView.locationPhone.text ?? "")
        if let url = URL(string: "telprompt://\(callablePhoneNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func checkForSafetyZoneProximity(_ sender: AnyObject) {
        print("Checking in foreground for safety zone proximity")
        let userLatitude = userLocation?.coordinate.latitude
        let userLongitude = userLocation?.coordinate.longitude
        
        if userLatitude != nil  && userLongitude != nil {
            ESPMobileAPI.checkForSafetyZoneProximity(with: (String(userLatitude!), String(userLongitude!))) {
                return
            }
        }
    }
    
    private func resetFilters() {
        for filter in filters {
            filter.backgroundColor = .espOrange
            filter.setTitleColor(UIColor.black, for: .normal)
        }
        
        enableFiltersButton.setImage(UIImage(named: "filter_black_filled"), for: .normal)
        UIView.animate(withDuration: 0.3, animations: {
            self.filterView.frame = CGRect(
                x: 1.5 * self.filterView.frame.width,
                y: self.filterView.frame.minY,
                width: self.filterView.frame.width,
                height: self.filterView.frame.height
            )
        })
    }
    
    public func modalSegue(segue: String) {
        if segue == "logOut" {
            guard let shouldUnwind = UserDefaults.standard.object(forKey: "rootVCIsPresent") as? Bool else { return }
            
            if shouldUnwind {
                performSegue(withIdentifier: segue, sender: self)
            } else {
                let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")
                
                present(viewController, animated: false)
            }
            
            renderSuccessState()
        } else if segue == "showFeedback" {
            if let feedbackPosition = UserDefaults.standard.value(forKey: "feedbackPosition") as? Int{
                switch feedbackPosition {
                case 1: performSegue(withIdentifier: segue, sender: self)
                case 7: performSegue(withIdentifier: "feedbackAlreadyProvided", sender: self)
                default:
                    Array(1...feedbackPosition).forEach {
                        navigationController?.pushViewController(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "page\($0)"), animated: false)
                    }
                }
            } else {
                performSegue(withIdentifier: segue, sender: self)
            }
        } else {
            performSegue(withIdentifier: segue, sender: self)
        }
    }
    
    private func setRegion(from miles: Int, with userLocation: CLLocation?) {
        if userLocation != nil {
            let scalingFactor = abs((cos(2 * .pi * userLocation!.coordinate.latitude / 360.0)))
            
            let span = MKCoordinateSpan(
                latitudeDelta: Double(miles) / 69.0,
                longitudeDelta:  Double(miles) / (scalingFactor * 69.0)
            )
            
            let region = MKCoordinateRegion(
                center: userLocation!.coordinate,
                span: span
            )
            
            self.mapView.setRegion(region, animated: false)
        }
    }
    
    private func regionToMiles() -> Int {
        let mRect = mapView.visibleMapRect
        let eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect))
        let westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect))
        let currentDistWideInMeters = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint)
        let miles = currentDistWideInMeters / 1609.34  // number of meters in a mile
        
        return Int(miles)
    }
    
    private func addLocationToMap(location: Location) {
        let pin = SafetyZoneAnnotation(location: location)
        mapView.addAnnotation(pin)
        displayedPins.append((pin, location.category))
    }
    
    // MARK: State configuration
    
    public func render(state: ViewModel) {
        DispatchQueue.main.async {
            switch (state) {
            case .preInitial(let preInitial): self.renderPreInitialState(state: preInitial)
            case .initial(let initial):       self.renderInitialState(state: initial)
            case .waiting:                    self.renderWaitingState()
            case .waitingWithFunctionality:   self.renderWaitingWithFunctionalityState()
            case .failure(let failure):       self.renderFailureState(state: failure)
            case .success:                    self.renderSuccessState()
            }
        }
    }
    
    private func renderPreInitialState(state: ViewModel.PreInitial) {
        invokeGetLocation = state.invokeGetLocation
        invokeReadyForUpdate = state.invokeReadyForUpdate
    }
    
    private func renderInitialState(state: ViewModel.Initial) {
        userLocation = state.userLocation
        setRegion(from: 5, with: userLocation!)
        errorView.isHidden = true
        waitingIndicator.stopAnimating()
        
        state.locations.forEach {  self.addLocationToMap(location: $0) }
        
        radiusSlider.isEnabled = true
        
        if let distressMode = UserDefaults.standard.value(forKey: "distressMode") as? Bool, distressMode {
            distressExitButton.isEnabled = true
            distressModeLabel.isHidden = false
            menuButton.isEnabled = false
        } else {
            distressExitButton.isEnabled = false
            distressModeLabel.isHidden = true
            menuButton.isEnabled = true
            Timer(
                timeInterval: 60,
                target: self,
                selector: #selector(checkForSafetyZoneProximity(_:)),
                userInfo: nil,
                repeats: true
                ).fire()
        }
    }
    
    private func renderWaitingWithFunctionalityState() {
        radiusSlider.isEnabled = false
        menuButton.isEnabled = false
        errorView.isHidden = true
        waitingIndicator.startAnimating()
    }
    
    private func renderWaitingState(with message: String? = nil) {
        menuButton.isEnabled = false
        radiusSlider.isEnabled = false
        
        displayedPins.forEach { self.mapView.removeAnnotation($0.0) }
        displayedPins = []
        
        if message != nil {
            errorView.isHidden = false
            errorMessage.text = message
            effectiveErrorView.layer.backgroundColor = UIColor(
                red: 1,
                green: 228 / 255,
                blue: 181 / 255,
                alpha: 1
            ).cgColor
        } else {
            errorView.isHidden = true
        }
        
        waitingIndicator.startAnimating()
    }
    
    private func renderFailureState(state: ViewModel.Failure) {
        menuButton.isEnabled = false
        radiusSlider.isEnabled = true
        effectiveErrorView.layer.backgroundColor = UIColor(
            red: 231 / 255,
            green: 76 / 255,
            blue: 61 / 255,
            alpha: 1
        ).cgColor
        
        errorView.isHidden = false
        errorMessage.text = state.message
        waitingIndicator.stopAnimating()
    }
    
    private func renderSuccessState() {
        // happens only during log out
        radiusSlider.isEnabled = true
        menuButton.isEnabled = true
        errorView.isHidden = true
        waitingIndicator.stopAnimating()
    }
    
    public func forceWaitingState(with message: String? = nil) {
        renderWaitingState(with: message)
    }
    
    public func forceFailureState(with message: String) {
        renderFailureState(state: ViewModel.Failure(message: message))
    }
}

// MARK: MKMapViewDelegate

extension SafetyZonesViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.view(for: userLocation)?.canShowCallout = false
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation")
        
        pinView = AnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        pinView?.canShowCallout = false
        
        var pinType = "map_pin"
        switch (annotation as? SafetyZoneAnnotation)?.location.category {
        case "hospital": pinType = "hospital_pin"
        case "police": pinType = "police_pin"
        case "fire_station": pinType = "fire_pin"
        default: pinType = "custom_pin"
        }
        
        pinView?.image = UIImage(named: pinType)?.castRetina(to: CGSize(width: 35, height: 45))
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let safetyZoneAnnotation = view.annotation as? SafetyZoneAnnotation {
            if safetyZoneAnnotation.location.category != "custom" {
                invokeGetLocation?(safetyZoneAnnotation.location.locationID) { location in
                    if let location = location {
                        let phoneNumber = location.phoneNumber
                        let attributedPhoneNumber = NSAttributedString(
                            string: phoneNumber,
                            attributes: [NSAttributedStringKey.underlineStyle : 1]
                        )
                        
                        let views = Bundle.main.loadNibNamed("SafetyZoneAnnotationView", owner: nil, options: nil)
                        if let safetyZoneAnnotationView = views?[0] as? SafetyZoneAnnotationView {
                            self.locationToSend = location
                            safetyZoneAnnotationView.showDetailButton.addTarget(self, action: #selector(self.detailButtonClicked), for: .touchUpInside)
                            
                            safetyZoneAnnotationView.locationName.text = safetyZoneAnnotation.location.name
                            safetyZoneAnnotationView.locationPhone.attributedText = attributedPhoneNumber
                            safetyZoneAnnotationView.locationAddress.text = safetyZoneAnnotation.location.address
                            
                            let phoneButton = UIButton(frame: safetyZoneAnnotationView.locationPhone.frame)
                            phoneButton.addTarget(self, action: #selector(self.callPhoneNumber), for: .touchUpInside)
                            safetyZoneAnnotationView.addSubview(phoneButton)
                            safetyZoneAnnotationView.center = CGPoint(
                                x: view.bounds.size.width / 2,
                                y: -safetyZoneAnnotationView.bounds.size.height * 0.52
                            )
                            
                            view.addSubview(safetyZoneAnnotationView)
                        }
                        
                        self.mapView.setCenter((view.annotation?.coordinate)!, animated: true)
                    }
                }
            } else {
                let attributedPhoneNumber = NSAttributedString(
                    string: Contact.formatPhoneNumber(phoneNumber: safetyZoneAnnotation.location.phoneNumber),
                    attributes: [NSAttributedStringKey.underlineStyle : 1]
                )
                
                let views = Bundle.main.loadNibNamed("SafetyZoneAnnotationView", owner: nil, options: nil)
                if let safetyZoneAnnotationView = views?[0] as? SafetyZoneAnnotationView {
                    self.locationToSend = safetyZoneAnnotation.location
                    safetyZoneAnnotationView.showDetailButton.addTarget(self, action: #selector(self.detailButtonClicked), for: .touchUpInside)
                    
                    safetyZoneAnnotationView.locationName.text = safetyZoneAnnotation.location.name
                    safetyZoneAnnotationView.locationPhone.attributedText = attributedPhoneNumber
                    safetyZoneAnnotationView.locationAddress.text = safetyZoneAnnotation.location.address
                    
                    let phoneButton = UIButton(frame: safetyZoneAnnotationView.locationPhone.frame)
                    phoneButton.addTarget(self, action: #selector(self.callPhoneNumber), for: .touchUpInside)
                    safetyZoneAnnotationView.addSubview(phoneButton)
                    
                    safetyZoneAnnotationView.center = CGPoint(
                        x: view.bounds.size.width / 2,
                        y: -safetyZoneAnnotationView.bounds.size.height * 0.52
                    )
                    
                    view.addSubview(safetyZoneAnnotationView)
                }
                
                self.mapView.setCenter((view.annotation?.coordinate)!, animated: true)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self) {
            for subview in view.subviews {
                subview.removeFromSuperview()
            }
            
            locationToSend = nil
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        let miles = regionToMiles()
        
        if miles > 20 {
            setRegion(from: 20, with: userLocation)
            radiusSlider.value = 20.0
            milesLabel.text = "20 mi"
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let miles = regionToMiles()
        
        if miles <= 20 {
            radiusSlider.value = Float(miles)
            milesLabel.text = String(miles) + " mi"
        }
    }
}
