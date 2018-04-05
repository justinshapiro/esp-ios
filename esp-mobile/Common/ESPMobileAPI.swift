//
//  ESPMobileAPI.swift
//  ESPMobileAPI
//
//  Created by Justin Shapiro on 11/11/17.
//  Copyright © 2017 Justin Shapiro. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

// MARK: Service Models

public struct Location {
    let latitude: Double
    let longitude: Double
    let name: String
    let address: String
    let locationID: String
    let phoneNumber: String
    let category: String
    let photoRef: String?
    var alertable: String?
    var description: String?
    
    // phone number that can be called through a URL can only have numbers
    static func getCallable(phoneNumber: String) -> String {
        return phoneNumber
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
    }
    
    // trim the geolocation for display purposes
    static func limitDigits(_ geoLocation: String, to limit: Int) -> String {
        let floatComponenets = geoLocation.components(separatedBy: ".")
        
        if floatComponenets.count > 1 {
            let floatingDigits = Array(floatComponenets[1])
            
            var limitedGeoLocation = floatComponenets[0] + "."
            floatingDigits.enumerated().forEach { i, digit in
                if i < limit {
                    limitedGeoLocation += String(digit)
                }
            }
            
            return limitedGeoLocation
        } else {
            return geoLocation
        }
    }
    
    // capitalizes the first letter of each word of the category for display purposes
    static func capitalize(word: String) -> String {
        let wordEnumerated = Array(word)
        
        var capitalizedWord: String = ""
        var shouldCapitalize = true
        wordEnumerated.forEach {
            if shouldCapitalize {
                capitalizedWord += String($0).uppercased()
                shouldCapitalize = false
            } else if $0 == "_" {
                shouldCapitalize = true
                capitalizedWord += " "
            } else {
                capitalizedWord += String($0)
            }
        }
        
        return capitalizedWord
    }
}

public struct UserInfo {
    let name: String
    let email: String
    let username: String
    let password: String
    let confirmPassword: String
    let oldPassword: String
}

public struct Contact {
    let id: String?
    let name: String
    let phone: String
    let groupID: String?
    
    static func formatPhoneNumber(phoneNumber: String) -> String {
        var formattedPhoneNumber: String = ""
        phoneNumber.enumerated().forEach { i, digit in
            if i == 0 {
                formattedPhoneNumber += "(\(digit)"
            } else if i == 3 {
                formattedPhoneNumber += ") \(digit)"
            } else if i == 6 {
                formattedPhoneNumber += "-\(digit)"
            } else {
                formattedPhoneNumber += "\(digit)"
            }
        }
        
        return formattedPhoneNumber
    }
}

public struct Feedback {
    var platform: String = ""
    var feedbackRound: String = ""
    
    var _1a: String = "" // "Rate our app"
    var _1b: String = "" // "Tell us what you like about the app"
    var _1c: String = "" // "Anything you don't like?"
    var _1d: String = "" // "How useful do you find the app?"
    var _1e: String = "" // "Rate the overall look-and-feel"
    var _1f: String = "" // "Would you recommend this app to a friend?"

    var _2a: String = "" // "How long did it take you to create an account?"
    var _2b: String = "" // "Was creating an account intuitive?"
    var _2c: String = "" // "What did you like about this experience?"
    var _2d: String = "" // "Anything you did't like?"
    var _2e: String = "" // "Rate the look-and-feel"

    var _3a: String = "" // "Did you find it easy to see the nearest safety-zone near you?"
    var _3b: String = "" // "Do you feel like a maximum radius of 20 miles is enough"
    var _3c: String = "" // "Tell us about any safety-zones near you that were not on the map"
    var _3d: String = "" // "Was there enough detail provided about each location?"
    var _3e: String = "" // "Do you feel like the safety-zone categories 'Hospital', 'Police' and 'Fire' are enough?"
    var _3f: String = "" // "What did you like about this experience?"
    var _3g: String = "" // "Anything you didn't like?"
    var _3h: String = "" // "Rate the look-and-feel"

    var _4a: String = "" // "Was adding emergency contains intuitive?"
    var _4b: String = "" // "Was creating alert groups from your emergency contacts intuitive?"
    var _4c: String = "" // "What did you like about this experience?
    var _4d: String = "" // "Anything you didn't like?"
    var _4e: String = "" // "Rate the look-and-feel"

    var _5a: String = "" // "Was adding custom safety-zone locations intuitive?"
    var _5b: String = "" // "What did you like about this experience?"
    var _5c: String = "" // "Anything you don't like?"
    var _5d: String = "" // "Was marking locations as 'non-alertable' an intuitive and smooth experience?"
    var _5e: String = "" // "Briefly describe your experience turing on/off alertable locations"
    var _5f: String = "" // "Rate the look-and-feel"

    var _6a: String = "" // "Did your emergency contacts receive a text message when you entered a safety-zone?"
    var _6b: String = "" // "Do you have any additional feedback regarding the emergency alert functionality?"
    var _6c: String = "" // (user's battery usage)
    
    init() {}
    
    init(tabularRepresentation: [String: Any]) {
        _1a = tabularRepresentation["1a"] as? String ?? ""
        _1b = tabularRepresentation["1b"] as? String ?? ""
        _1c = tabularRepresentation["1c"] as? String ?? ""
        _1d = tabularRepresentation["1d"] as? String ?? ""
        _1e = tabularRepresentation["1e"] as? String ?? ""
        _1f = tabularRepresentation["1f"] as? String ?? ""
        _2a = tabularRepresentation["2a"] as? String ?? ""
        _2b = tabularRepresentation["2b"] as? String ?? ""
        _2c = tabularRepresentation["2c"] as? String ?? ""
        _2d = tabularRepresentation["2d"] as? String ?? ""
        _2e = tabularRepresentation["2e"] as? String ?? ""
        _3a = tabularRepresentation["3a"] as? String ?? ""
        _3b = tabularRepresentation["3b"] as? String ?? ""
        _3c = tabularRepresentation["3c"] as? String ?? ""
        _3d = tabularRepresentation["3d"] as? String ?? ""
        _3e = tabularRepresentation["3e"] as? String ?? ""
        _3f = tabularRepresentation["3f"] as? String ?? ""
        _3g = tabularRepresentation["3g"] as? String ?? ""
        _3h = tabularRepresentation["3h"] as? String ?? ""
        _4a = tabularRepresentation["4a"] as? String ?? ""
        _4b = tabularRepresentation["4b"] as? String ?? ""
        _4c = tabularRepresentation["4c"] as? String ?? ""
        _4d = tabularRepresentation["4d"] as? String ?? ""
        _4e = tabularRepresentation["4e"] as? String ?? ""
        _5a = tabularRepresentation["5a"] as? String ?? ""
        _5b = tabularRepresentation["5b"] as? String ?? ""
        _5c = tabularRepresentation["5c"] as? String ?? ""
        _5d = tabularRepresentation["5d"] as? String ?? ""
        _5e = tabularRepresentation["5e"] as? String ?? ""
        _5f = tabularRepresentation["5f"] as? String ?? ""
        _6a = tabularRepresentation["6a"] as? String ?? ""
        _6b = tabularRepresentation["6b"] as? String ?? ""
        _6c = tabularRepresentation["6c"] as? String ?? ""
    }
    
    func tabularRepresentation(safe: Bool = false) -> [String: String] {
        func clean(_ s: String) -> String {
            if safe {
            return s
                .replacingOccurrences(of: "&", with: "and")
                .replacingOccurrences(of: "=", with: "equals")
                .replacingOccurrences(of: "?", with: "[question mark]")
                .replacingOccurrences(of: "\"", with: "[quote]")
            } else {
                return s
            }
        }
        
        return [
            "platform": platform,
            "feedback_round": feedbackRound,
            "1a": clean(_1a), "1b": clean(_1b), "1c": clean(_1c), "1d": clean(_1d), "1e": clean(_1e), "1f": clean(_1f),
            "2a": clean(_2a), "2b": clean(_2b), "2c": clean(_2c), "2d": clean(_2d), "2e": clean(_2e),
            "3a": clean(_3a), "3b": clean(_3b), "3c": clean(_3c), "3d": clean(_3d), "3e": clean(_3e), "3f": clean(_3f), "3g": clean(_3g), "3h": clean(_3h),
            "4a": clean(_4a), "4b": clean(_4b), "4c": clean(_4c), "4d": clean(_4d), "4e": clean(_4e),
            "5a": clean(_5a), "5b": clean(_5b), "5c": clean(_5c), "5d": clean(_5d), "5e": clean(_5e), "5f": clean(_5f),
            "6a": clean(_6a), "6b": clean(_6b), "6c": clean(_6c)
        ]
    }
}

// MARK: Provider

public final class ESPMobileAPI {
    public enum ESPResponse {
        case success
        case successWithData(Response)
        case failure(Failure)
        
        public struct Response {
            let object: Any
        }
        
        public struct Failure {
            let message: String
        }
    }
    
    public init() {}
    
    private enum ESPJsonResponse {
        case espSuccess(Any)
        case espConnectionFailure(String)
        case espLogicFailure
    }
    
    private static func parseJsonResponse(_ response: Data?) -> ESPJsonResponse {
        if let response = response {
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: response, options: .allowFragments) as? [String: Any] {
                    if let payload = jsonResponse["ESP-Response"] {
                        return .espSuccess(payload)
                    } else {
                        return .espLogicFailure
                    }
                } else {
                    return .espConnectionFailure(connectionError)
                }
            } catch {
                return .espConnectionFailure(connectionError)
            }
        } else {
            return .espConnectionFailure(connectionError)
        }
    }
    
    private static func loadCookies() {
        if let cookieArray = UserDefaults.standard.array(forKey: "cookies") as? [[HTTPCookiePropertyKey: Any]] {
            for cookieProperties in cookieArray {
                if let cookie = HTTPCookie(properties: cookieProperties) {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
        }
    }
    
    private static let connectionError = "Could not connect to server. Please check your Internet connection"
    
    private static func geoJsonToLocation(geoJson: [String: Any]) -> Location {
        let geometry = geoJson["geometry"] as? [String: Any] ?? [:]
        let coordinates = geometry["coordinates"] as? [Double] ?? [-1, -1]
        let latitude = coordinates[0]
        let longitude = coordinates[1]
        
        let properties = geoJson["properties"] as? [String: Any] ?? [:]
        let name = properties["name"] as? String ?? ""
        let address = properties["address"] as? String ?? ""
        let category = properties["category"] as? String ?? ""
        let locationID = properties["location_id"] as? String ?? ""
        let phoneNumber = properties["phone_number"] as? String
        let photoRef = properties["photo_ref"] as? String
        
        var alertable: String = "true"
        if let _alertable = properties["alertable"] as? Bool {
            if !_alertable {
                alertable = "false"
            } 
        }
        
        return Location(
            latitude: latitude,
            longitude: longitude,
            name: name,
            address: address,
            locationID: locationID,
            phoneNumber: phoneNumber ?? "",
            category: category,
            photoRef: photoRef,
            alertable: alertable,
            description: nil
        )
    }
    
    private static func locationsFromAlerts(jsonLocations: [[String: Any]]) -> [Location] {
        var locations: [Location] = []
        
        jsonLocations.forEach {
            let name = $0["name"] as? String ?? ""
            let locationID = $0["location_id"] as? String ?? ""
            let latitude = $0["latitude"] as? Double ?? -1
            let longitude = $0["longitude"] as? Double ?? -1
            let alertable = $0["alertable"] as? Bool ?? true ? "true" : "false"
            
            locations.append(Location(
                latitude: latitude,
                longitude: longitude,
                name: name,
                address: "",
                locationID: locationID,
                phoneNumber: "",
                category: "",
                photoRef: nil,
                alertable: alertable,
                description: nil
            ))
        }
        
        return locations
    }
    
    private static func geoJsonToLocations(geoJson: [String: Any]) -> [Location] {
        let features = (geoJson["GeoJson"] as? [String: Any])?["features"] as? [[String: Any]] ?? []
        
        var locations: [Location] = []
        features.forEach {
            locations.append(geoJsonToLocation(geoJson: $0))
        }
        
        return locations
    }
    
    private static func jsonToContacts(json: Any) -> [Contact] {
        var contacts: [Contact] = []
        
        (json as? [Any])?.forEach {
            let contact = $0 as? [String: Any] ?? [:]
            
            contacts.append(Contact(
                id: contact["id"] as? String ?? "",
                name: contact["name"] as? String ?? "",
                phone: contact["phone"] as? String ?? "",
                groupID: contact["group_id"] as? Int ?? nil != nil ? "\(contact["group_id"]!)" : nil
            ))
        }
        
        return contacts
    }
    
    // Route: POST /api/v1/authentication/login
    public static func login(loginID: String, password: String, _ completion: @escaping (ESPResponse) -> ()) {
        let endpoint = "https://espmobile.org/api/v1/authentication/login"
        let queryParameters: Parameters = [
            "username": loginID,
            "password": password
        ]
        
        Alamofire.request(endpoint, method: .post, parameters: queryParameters, encoding: URLEncoding.queryString).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess(let payload):
                // cache user ID
                let espResponse = payload as? [String: String]
                if let loggedInUser = espResponse?["user_id"] {
                    UserDefaults.standard.set(loggedInUser, forKey: "loggedInUser")
                }
                
                // cache cookies
                let headerFields = $0.response?.allHeaderFields as? [String: String] ?? [:]
                let url = $0.response?.url
                let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url!)
                var cookieArray = [[HTTPCookiePropertyKey: Any]]()
                cookies.forEach {
                    if let properties = $0.properties {
                        cookieArray.append(properties)
                    }
                }
                
                UserDefaults.standard.set(cookieArray, forKey: "cookies")
                UserDefaults.standard.synchronize()
                
                completion(.success)
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Invalid login ID and/or password. Please try again")))
            }
        }
    }
    
    // GET /api/v1/authentication/logout
    public static func logout(_ completion: @escaping (ESPResponse) -> ()) {
        let endpoint = "https://espmobile.org/api/v1/authentication/logout"
        
        loadCookies()
        Alamofire.request(endpoint, method: .get, encoding: URLEncoding.queryString).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess:
                // remove logged in user from cache
                UserDefaults.standard.removeObject(forKey: "loggedInUser")
                UserDefaults.standard.removeObject(forKey: "cookies")
                UserDefaults.standard.removeObject(forKey: "User Name")
                UserDefaults.standard.removeObject(forKey: "User Email")
                Feedback().tabularRepresentation().keys.forEach {
                    UserDefaults.standard.removeObject(forKey: $0)
                }
                UserDefaults.standard.synchronize()
                
                completion(.success)
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Unable to log you out. Try restarting the application")))
            }
        }
    }

    // Route GET /api/v1/locations
    public static func safetyZones(latitude: String, longitude: String, radius: String, _ completion: @escaping (ESPResponse) ->()) {
        let endpoint = "https://espmobile.org/api/v1/locations"
        var queryParameters: Parameters = [
            "latitude": latitude,
            "longitude": longitude,
            "radius": radius
        ]
        
        if let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String {
            queryParameters["user_id"] = userID
        }
        
        loadCookies()
        Alamofire.request(endpoint, method: .get, parameters: queryParameters, encoding: URLEncoding.queryString).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess(let payload): completion(.successWithData(.init(object: geoJsonToLocations(geoJson: payload as? [String: Any] ?? [:]))))
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "An error occured retrieving safety-zone locations")))
            }
        }
    }
    
    // Route: GET /api/v1/locations/{id}
    public static func getLocation(locationID: String, _ completion: @escaping (ESPResponse) -> ()) {
        let endpoint = "https://espmobile.org/api/v1/locations/\(locationID)"
        
        loadCookies()
        Alamofire.request(endpoint, method: .get, encoding: URLEncoding.queryString).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess(let payload): completion(.successWithData(.init(object: geoJsonToLocation(geoJson: payload as? [String: Any] ?? [:]))))
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "An error occured retrieving safety-zone location")))
            }
        }
    }
    
    // Route: GET /api/v1/users/{id}
    public static func getUserInfo(_ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else {
            completion(.failure(.init(message: "You must login to view this information")))
            return
        }
        
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)"
        
        Alamofire.request(endpoint, method: .get, encoding: URLEncoding.queryString).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess(let payload):
                let userInfo = (payload as? [Any])?[0] as? [String: Any]
                
                let name = userInfo?["name"] as? String ?? "Your Name"
                let email = userInfo?["email"] as? String ?? "Your Email"
                let username = userInfo?["username"] as? String ?? ""
                
                completion(.successWithData(.init(object: UserInfo(
                    name: name,
                    email: email,
                    username: username,
                    password: "",
                    confirmPassword: "",
                    oldPassword: ""
                ))))
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "An error occured fetching your information")))
            }
        }
    }
    
    // Route: POST /api/v1/users
    public static func addUserAndLogin(userInfo: UserInfo, _ completion: @escaping (ESPResponse) -> ()) {
        if userInfo.password == userInfo.confirmPassword {
            let endpoint = "https://espmobile.org/api/v1/users"
            let queryParameters: Parameters = [
                "authentication_type": "1",
                "name": userInfo.name,
                "username": userInfo.username,
                "email": userInfo.email,
                "password": userInfo.password
            ]
            
            Alamofire.request(endpoint, method: .post, parameters: queryParameters, encoding: URLEncoding.queryString).responseJSON {
                switch (parseJsonResponse($0.data)) {
                case .espSuccess:
                    // successful account creation, so automatically log them in with the credentials they have alread supplied
                    login(loginID: userInfo.username, password: userInfo.password) { result in
                        switch (result) {
                        case .successWithData: break
                        case .success: completion(.success)
                        case .failure: completion(.failure(.init(message: "Account was created but automatic login failed")))
                        }
                    }
                case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
                case .espLogicFailure: completion(.failure(.init(message: "An error occured in creating your account")))
                }
            }
        } else {
            completion(.failure(.init(message: "Passwords must match")))
        }
    }
    
    // Route: PUT /api/v1/users/{id}/name
    public static func updateUserName(userName: String, _ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/name"
        let queryParameters: Parameters = [
            "name": userName
        ]
        
        Alamofire.request(endpoint, method: .put, parameters: queryParameters, encoding: URLEncoding.queryString).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess:
                // save user info to UserDefaults
                UserDefaults.standard.set(userName, forKey: "User Name")
                UserDefaults.standard.synchronize()
                completion(.success)
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Failed to update Name")))
            }
        }
    }
    
    // Route PUT /api/v1/users/{id}/email
    public static func updateUserEmail(userEmail: String, _ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/email"
        let queryParameters: Parameters = [
            "email": userEmail
        ]
        
        Alamofire.request(endpoint, method: .put, parameters: queryParameters, encoding: URLEncoding.queryString).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess:
                // save user info to UserDefaults
                UserDefaults.standard.set(userEmail, forKey: "User Email")
                UserDefaults.standard.synchronize()
                completion(.success)
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Failed to update Email")))
            }
        }
    }
    
    // Route: DELETE /api/v1/users/{id}
    public static func deleteUser(_ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)"
        
        // logout user first
        logout { logoutResponse in
            switch (logoutResponse) {
            case .successWithData: break
            case .success:
                // user is logged out, so now delete their account
                Alamofire.request(endpoint, method: .delete).responseJSON {
                    switch (parseJsonResponse($0.data)) {
                    case .espSuccess: completion(.success)
                    case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
                    case .espLogicFailure: completion(.failure(.init(message: "Failed to delete your account")))
                    }
                }
            case .failure: completion(logoutResponse)
            }
        }
    }
    
    // Route: GET /api/v1/users/{id}/locations
    public static func getUserLocations(latitude: String? = nil, longitude: String? = nil, radius: String? = nil, _ completion: @escaping (ESPResponse) ->()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/locations"
        
        if latitude != nil && longitude != nil && radius != nil {
            let queryParameters: Parameters = [
                "latitude": latitude!,
                "longitude": longitude!,
                "radius": radius!
            ]
            
            Alamofire.request(endpoint, method: .get, parameters: queryParameters).responseJSON {
                switch (parseJsonResponse($0.data)) {
                case .espSuccess(let payload): completion(.successWithData(.init(object: geoJsonToLocations(geoJson: payload as? [String: Any] ?? [:]))))
                case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
                case .espLogicFailure: completion(.failure(.init(message: "An error occured retrieving safety-zone locations")))
                }
            }
        } else {
            Alamofire.request(endpoint, method: .get).responseJSON {
                switch (parseJsonResponse($0.data)) {
                case .espSuccess(let payload): completion(.successWithData(.init(object: geoJsonToLocations(geoJson: payload as? [String: Any] ?? [:]))))
                case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
                case .espLogicFailure: completion(.failure(.init(message: "An error occured retrieving safety-zone locations")))
                }
            }
        }
    }
    
    // Route: GET /api/v1/users/{id}/locations/{id}
    public static func userLocation(locationID: String, _ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/locations/\(locationID)"
        
        Alamofire.request(endpoint, method: .get).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess(let payload): completion(.successWithData(.init(object: geoJsonToLocations(geoJson: payload as? [String: Any] ?? [:]))))
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "An error occured retrieving custom locations")))
            }
        }
    }
    
    // Route: POST /api/v1/users/{id}/locations
    public static func addCustomLocation(location: Location, _ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/locations"
        let queryParameters: Parameters = [
            "name": location.name,
            "latitude": location.latitude,
            "longitude": location.longitude,
            "address": location.address,
            "phone_number": location.phoneNumber,
            "description": location.description ?? ""
        ]
        
        Alamofire.request(endpoint, method: .post, parameters: queryParameters, encoding: URLEncoding.queryString).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess:
                UserDefaults.standard.set(true, forKey: "shouldUpdateMap")
                UserDefaults.standard.synchronize()
                
                completion(.success)
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Error adding custom location")))
            }
        }
    }
    
    // Route: DELETE /api/v1/user/{id}/locations/{id}
    public static func deleteCustomLocation(locationID: String, _ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/locations/\(locationID)"
        
        Alamofire.request(endpoint, method: .delete).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess:
                UserDefaults.standard.set(true, forKey: "shouldUpdateMap")
                UserDefaults.standard.synchronize()
                completion(.success)
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Error deleting custom location")))
            }
        }
    }
    
    // Route: GET /api/v1/locations/photo
    public static func getLocationPhoto(photoRef: String, _ completion: @escaping (ESPResponse) -> ()) {
        let endpoint = "https://espmobile.org/api/v1/locations/photo"
        let queryParameters: Parameters = [
            "photo_ref": photoRef
        ]
        
        Alamofire.request(endpoint, method: .get, parameters: queryParameters).responseImage {
            if let image = $0.result.value {
                completion(.successWithData(.init(object: image)))
            } else {
                completion(.failure(.init(message: "Could not get image for this location")))
            }
        }
    }
    
    // Route: GET /api/v1/user/{id}/contacts
    public static func getContacts(_ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/contacts"
        
        Alamofire.request(endpoint, method: .get).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess(let payload): completion(.successWithData(.init(object: jsonToContacts(json: payload))))
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Error retreiving emergency contacts")))
            }
        }
    }
    
    // Route: POST /api/v1/user/{id}/contacts
    public static func addContact(contact: Contact, _ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/contacts"
        let queryParameters: Parameters = [
            "name": contact.name,
            "phone": contact.phone
        ]
        
        Alamofire.request(endpoint, method: .post, parameters: queryParameters, encoding: URLEncoding.queryString).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess: completion(.success)
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Error adding emergency contact")))
            }
        }
    }
    
    // Route: GET /api/v1/user/{id}/contacts/{id}
    public static func getContact(contactID: String, _ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/contacts/\(contactID)"
        
        Alamofire.request(endpoint, method: .get).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess(let payload): completion(.successWithData(.init(object: jsonToContacts(json: payload)[0])))
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Error retreiving emergency contact")))
            }
        }
    }
    
    // Route: PUT /api/v1/user/{id}/contact/{id}/phone
    public static func updateContactPhone(contactID: String, contactPhone: String, _ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/contacts/\(contactID)/phone"
        let queryParameters: Parameters = [
            "phone_number": contactPhone
        ]
        
        Alamofire.request(endpoint, method: .put, parameters: queryParameters, encoding: URLEncoding.queryString).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess: completion(.success)
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Error updating emergency contact phone number")))
            }
        }
    }
    
    // Route: DELETE /api/v1/user/{id}/contacts/{id}
    public static func deleteContact(contactID: String, _ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/contacts/\(contactID)"
        
        Alamofire.request(endpoint, method: .delete).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess: completion(.success)
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Error deleting emergency contact")))
            }
        }
    }
    
    // ROUTE: POST /api/v1/user/{id}/contacts/group
    public static func addContactGroup(contactIDs: [String], _ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/contacts/group"
        let queryParameters: Parameters = [
            "contact_ids": contactIDs.reduce("[") { if $0 != "[" { return $0 + ", \"\($1)\"" } else { return $0 + "\"\($1)\"" } } + "]"
        ]
        
        Alamofire.request(endpoint, method: .post, parameters: queryParameters, encoding: URLEncoding.queryString).responseJSON {
            switch (parseJsonResponse($0.data)) {
                case .espSuccess: completion(.success)
                case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
                case .espLogicFailure: completion(.failure(.init(message: "Error deleting emergency contact")))
            }
        }
    }
    
    // Route: DELETE /api/v1/user/{id}/contacts/group
    public static func deleteContactGroup(_ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/contacts/group"
            
        Alamofire.request(endpoint, method: .delete).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess: completion(.success)
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Error updating contact groups")))
            }
        }
    }
    
    // Route: GET /api/v1/users/{id}/alert
    public static func getAlerts(_ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/alert"
        
        Alamofire.request(endpoint, method: .get).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess(let payload):
                let responseContent = payload as? [Any] ?? []
                if responseContent.count > 0 {
                    let locations = (responseContent[0] as? [String: Any] ?? [:])["locations"] as? [[String: Any]] ?? []
                    completion(.successWithData(.init(object: locationsFromAlerts(jsonLocations: locations))))
                } else {
                    completion(.successWithData(.init(object: [])))
                }
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Error retreiving alert exceptions")))
            }
        }
    }
    
    // Route: POST /api/v1/users/{id}/alert
    public static func addAlert(locationID: String, alertable: String, _ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/alert"
        let queryParameters: Parameters = [
            "location_id": locationID,
            "alertable": alertable
        ]
        
        Alamofire.request(endpoint, method: .post, parameters: queryParameters, encoding: URLEncoding.queryString).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess: completion(.success)
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Error adding new alertable")))
            }
        }
    }
    
    // Route: DELETE /api/v1/users/{id}/alert/{id}
    public static func deleteAlert(locationID: String, _ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/alert"
        let queryParameters: Parameters = [
            "location_id": locationID
        ]
        
        Alamofire.request(endpoint, method: .delete, parameters: queryParameters).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess: completion(.success)
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Error deleting alertable")))
            }
        }
    }
    
    // Route: GET /api/v1/users/{id}/password
    public static func getPassword(_ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        let endpoint = "https://espmobile.org/api/v1/users/\(userID)/password"
        
        Alamofire.request(endpoint, method: .get).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess(let payload):
                let password = (payload as? [[String: String]])?[0]["password"] ?? ""
                completion(.successWithData(.init(object: password)))
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Error validating password")))
            }
        }
    }
    
    // Route: PUT /api/v1/users/{id}/password
    public static func updatePassword(oldPassword: String, newPassword: String, _ completion: @escaping (ESPResponse) -> ()) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { completion(.failure(.init(message: "You are not logged in"))); return }
        getPassword { result in
            switch (result) {
            case .success: break
            case .successWithData(let data):
                let currentPassword = data.object as? String ?? ""
                
                if currentPassword == oldPassword {
                    let endpoint = "https://espmobile.org/api/v1/users/\(userID)/password"
                    let queryParameters: Parameters = [
                        "new_password": newPassword
                    ]
                    
                    Alamofire.request(endpoint, method: .put, parameters: queryParameters, encoding: URLEncoding.queryString).responseJSON {
                        switch (parseJsonResponse($0.data)) {
                        case .espSuccess: completion(.success)
                        case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
                        case .espLogicFailure: completion(.failure(.init(message: "Error updating password")))
                        }
                    }
                } else {
                    completion(.failure(.init(message: "Current password is incorrect")))
                }
            case .failure(let failure): completion(.failure(.init(message: failure.message)))
            }
        }
    }
    
    // Route: POST /api/v1/notification
    public static func sendNotification(locationID: String, category: String) {
        guard let userID = UserDefaults.standard.value(forKey: "loggedInUser") as? String else { return }
        let endpoint = "https://espmobile.org/api/v1/notification"
        let queryParameters: Parameters = [
            "user_id": userID,
            "location_id": locationID,
            "location_type": category
        ]
        
        Alamofire.request(endpoint, method: .post, parameters: queryParameters, encoding: URLEncoding.queryString).responseJSON {
            switch (parseJsonResponse($0.data)) {
            case .espSuccess: print("Notification sent successfully")
            case .espConnectionFailure(let failure): print("Sending notification failed with \(failure)")
            case .espLogicFailure: print("Sending notification failed with logic error")
            }
        }
    }
    
    // ROUTE: POST /api/v1/feedback
    public static func sendFeedback(feedback: Feedback, _ completion: @escaping (ESPResponse) -> ()) {
        let endpoint = "https://espmobile.org/api/v1/feedback"
        let queryParameters: Parameters = feedback.tabularRepresentation(safe: true)
        
        Alamofire.request(endpoint, method: .post, parameters: queryParameters, encoding: URLEncoding.queryString).responseJSON { response in
            switch (parseJsonResponse(response.data)) {
            case .espSuccess: completion(.success)
            case .espConnectionFailure(let failure): completion(.failure(.init(message: failure)))
            case .espLogicFailure: completion(.failure(.init(message: "Error submitting feedback")))
            }
        }
    }
    
    public static func checkForSafetyZoneProximity(with userLocation: (String, String), _ completion: @escaping () -> ()) {
        print("Performing proximity check")
        safetyZones(latitude: userLocation.0, longitude: userLocation.1, radius: "10") {
            switch ($0) {
            case .success: break
            case .successWithData(let data):
                let locations = data.object as? [Location] ?? []
                if locations.count > 0 {
                    let userLocation = locations[0]
                    
                    // prevent the same notification being sent
                    let lastAlertedLocation = UserDefaults.standard.value(forKey: "alertForLocationSent") as? String
                    if userLocation.locationID != lastAlertedLocation {
                        if let alertable = userLocation.alertable {
                            if alertable == "true" {
                                var effectiveCategory = "google"
                                if userLocation.category == "custom" {
                                    effectiveCategory = "custom"
                                }
                                
                                print("Sending notification")
                                sendNotification(locationID: userLocation.locationID, category: effectiveCategory)
                                print("Done performing proximity check")
                                
                                UserDefaults.standard.set(userLocation.locationID, forKey: "alertForLocationSent")
                                UserDefaults.standard.synchronize()
                                
                                completion()
                            }
                        }
                    } else {
                        print("Done performing proximity check since we already sent a notification to that location")
                    }
                } else {
                    print("Done performing proximity check")
                }
            case .failure:
                print("Done performing proximity check")
                break
            }
        }
    }
}

extension Sequence where Iterator.Element == Location {
    func tabularRepresentation() -> [[String: String]] {
        var representation: [[String: String]] = []
        self.sorted(by: { $0.name < $1.name }).forEach {
            representation.append([
                "id": $0.locationID,
                "name": $0.name,
                "latitude": String($0.latitude),
                "longitude": String($0.longitude)
            ])
        }
        
        return representation
    }
}

extension Sequence where Iterator.Element == Contact {
    func tabularRepresentation() -> [[String: String?]] {
        var representation: [[String: String?]] = []
        self.sorted(by: { $0.name < $1.name }).forEach {
            representation.append([
                "id": $0.id ?? "",
                "name": $0.name,
                "phone": Contact.formatPhoneNumber(phoneNumber: $0.phone),
                "group_id": $0.groupID
            ])
        }
        
        return representation
    }
    
    func sectionalRepresentation() -> [[[String: String?]]] {
        var sectionalRepresentation: [[[String: String?]]] = []
        
        var currentSectionKey: String = ""
        var currentSection: [[String: String?]] = []
        let tabularRepresentation = self.tabularRepresentation()
        tabularRepresentation.enumerated().forEach { (i, contact) in
            if currentSectionKey == "" {
                currentSectionKey = String(Array(contact["name"]!!)[0]).uppercased()
                currentSection.append(contact)
                
                if tabularRepresentation.count - 1 == i {
                    sectionalRepresentation.append(currentSection)
                }
            } else {
                let currentKey = String(Array(contact["name"]!!)[0]).uppercased()
                if currentKey != currentSectionKey {
                    sectionalRepresentation.append(currentSection)
                    currentSection = [contact]
                    currentSectionKey = currentKey
                    
                    if tabularRepresentation.count - 1 == i {
                        sectionalRepresentation.append(currentSection)
                    }
                } else {
                    currentSection.append(contact)
                }
            }
        }
        
        return sectionalRepresentation
    }
}
