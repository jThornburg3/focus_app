//
//  AuthApi.swift
//  FocusInterests
//
//  Created by jonathan thornburg on 3/12/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import Foundation

struct AuthApi {
    
    static let defaults = UserDefaults.standard
    
    static func set(loggedIn: LoginTypes) {
        defaults.set(loggedIn.rawValue, forKey: "Login")
    }
    
    static func set(firebaseUid: String?) {
        if let id = firebaseUid {
            defaults.set(id, forKey: "firebaseUid")
        }
    }
    
    static func getFirebaseUid() -> String? {
        if let uid = defaults.object(forKey: "firebaseUid") as? String {
            return uid
        }
        return nil
    }
    
    static func set(userEmail: String?) {
        if let email = userEmail {
            defaults.set(email, forKey: "userEmail")
        }
    }
    
    static func getUserEmail() -> String? {
        if let email = defaults.object(forKey: "userEmail") as? String {
            return email
        }
        return nil
    }
    
    static func set(facebookToken: String?) {
        defaults.set(facebookToken, forKey: "facebookAccessToken")
    }
    
    static func getFacebookToken() -> String? {
        if let facebookToken = defaults.object(forKey: "facebookAccessToken") as? String {
            return facebookToken
        }
        return nil
    }
    
    static func set(googleToken: String?) {
        if let token = googleToken {
            defaults.set(token, forKey: "googleAccessToken")
        }
    }
    
    static func getGoogleToken() -> String? {
        if let token = defaults.object(forKey: "googleAccessToken") as? String {
            return token
        }
        return nil
    }
    
    static func setDefaultsForLogout() {
        defaults.set(nil, forKey: "userEmail")
        defaults.set(nil, forKey: "facebookAccessToken")
        defaults.set(nil, forKey: "googleAccessToken")
    }
    
    static func setEmailConfirmationSent() {
        defaults.set(true, forKey: "emailConfirmationSent")
    }
    
    static func getEmailConfirmationSent() -> Bool {
        return defaults.bool(forKey: "emailConfirmationSent")
    }
    
    static func setEmailConfirmed(confirmed: Bool) {
        defaults.set(confirmed, forKey: "emailConfirmed")
    }
    
    static func getEmailConfirmed() -> Bool {
        return defaults.bool(forKey: "emailConfirmed")
    }
}
