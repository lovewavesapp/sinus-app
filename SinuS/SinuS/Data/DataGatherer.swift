//
//  DataGatherer.swift
//  SinuS
//
//  Created by Loe Hendriks on 06/09/2022.
//

import Foundation
import UIKit
import Get
import SwiftKeychainWrapper

/**
    Internal struct to hold data/date's
 */
private struct GraphDataPoint: Codable {
    let date: String
    let value: Int
    let deleted_at: String?
    let latitude: Double?
    let longitude: Double?
    let tags: String?
    let description: String?
}

/**
    Class responsible for storing and retrieve data to and from the backend.
 */
public class DataManager {
    // endpoints
    private static var userUrl = "https://www.lovewaves.antrum-technologies.nl/api/sinus"
    private static var dataUrl = "https://www.lovewaves.antrum-technologies.nl/api/sinusvalue/"

    private var users = [SinusUserData]()
    private var logHelper = LogHelper()

    /**
        Register call to the backend.
     */
    public func register(
        name: String,
        email: String,
        password: String,
        confirmPassword: String) -> AuthenticationResult? {
        let registerUrl = "https://lovewaves.antrum-technologies.nl/api/register?"
        let parameters: [String: Any] = [
            "name": name, "email": email, "password": password, "confirm_password": confirmPassword]
        let decoder = JSONDecoder()
        var request = RestApiHelper.createRequest(type: "POST", url: registerUrl, auth: false)

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }

        var result: AuthenticationResult?
        let data = RestApiHelper.perfomRestCall(request: request)

        do {
            result = try decoder.decode(AuthenticationResult.self, from: data!)
        } catch {
            let returnedData = (String(bytes: data!, encoding: .utf8) ?? "")
            let errMsg = "Unable to register: \(returnedData)"
            self.logHelper.logMsg(level: "error", message: errMsg)
            print(errMsg)
        }

        return result
    }

    /**
        Login call to the backend.
     */
    public func login(email: String, password: String) -> AuthenticationResult? {
        let loginUrl = "https://lovewaves.antrum-technologies.nl/api/login?"
        let parameters: [String: Any] = ["email": email, "password": password]
        let decoder = JSONDecoder()
        var request = RestApiHelper.createRequest(type: "POST", url: loginUrl, auth: false)

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }

        var result: AuthenticationResult?
        let data = RestApiHelper.perfomRestCall(request: request)

        do {
            result = try decoder.decode(AuthenticationResult.self, from: data!)
        } catch {
            let returnedData = (String(bytes: data!, encoding: .utf8) ?? "")
            let errMsg = "Unable to login: \(returnedData)"
            self.logHelper.logMsg(level: "error", message: errMsg)
            print(errMsg)
        }

        return result
    }

    public func forgotPassword(email: String) -> AuthenticationResult? {
        let loginUrl = "https://lovewaves.antrum-technologies.nl/api/forgot-password"
        let parameters: [String: Any] = ["email": email]
        let decoder = JSONDecoder()
        var request = RestApiHelper.createRequest(type: "POST", url: loginUrl, auth: false)

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }

        var result: AuthenticationResult?
        let data = RestApiHelper.perfomRestCall(request: request)

        do {
            result = try decoder.decode(AuthenticationResult.self, from: data!)
        } catch {
            let returnedData = (String(bytes: data!, encoding: .utf8) ?? "")
            let errMsg = "Unable to process forgot password request: \(returnedData)"
            self.logHelper.logMsg(level: "error", message: errMsg)
            print(errMsg)
        }

        return result
    }

    public func resetPassword(token: String, email: String, password: String, confirmPassword: String) -> AuthenticationResult? {
        let loginUrl = "https://lovewaves.antrum-technologies.nl/api/reset-password"
        let parameters: [String: Any] = [
            "token": token,
            "email": email,
            "password": password,
            "password_confirmation": confirmPassword
        ]
        let decoder = JSONDecoder()
        var request = RestApiHelper.createRequest(type: "POST", url: loginUrl, auth: false)

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }

        var result: AuthenticationResult?
        let data = RestApiHelper.perfomRestCall(request: request)

        do {
            result = try decoder.decode(AuthenticationResult.self, from: data!)
        } catch {
            let returnedData = (String(bytes: data!, encoding: .utf8) ?? "")
            let errMsg = "Unable to reset password: \(returnedData)"
            self.logHelper.logMsg(level: "error", message: errMsg)
            print(errMsg)
        }

        return result
    }

    public func isTokenValid() -> Bool {
        let url = "https://lovewaves.antrum-technologies.nl/api/user"
        let decoder = JSONDecoder()
        let request = RestApiHelper.createRequest(type: "GET", url: url, auth: true)

        var result: UserData?
        let data = RestApiHelper.perfomRestCall(request: request)

        do {
            result = try decoder.decode(UserData.self, from: data!)
            
            // Update fcm_token with deviceToken if not equal
            let deviceToken: String = KeychainWrapper.standard.string(forKey: "deviceToken") ?? ""
            if (deviceToken != "" && result?.fcm_token != deviceToken) {
                print("Updating FCM token...")
            } else {
                print("FCM token is up-to-date")
            }
            
            return true
        } catch {
            print("Error info: \(error)")
            return false
        }
    }

    public func getCurrentUser() -> UserData? {
        let url = "https://lovewaves.antrum-technologies.nl/api/user"
        let decoder = JSONDecoder()
        let request = RestApiHelper.createRequest(type: "GET", url: url, auth: true)

        var result: UserData?
        let data = RestApiHelper.perfomRestCall(request: request)

        do {
            result = try decoder.decode(UserData.self, from: data!)
        } catch {
            let returnedData = (String(bytes: data!, encoding: .utf8) ?? "")
            let errMsg = "Unable to login: \(returnedData)"
            self.logHelper.logMsg(level: "error", message: errMsg)
            print(errMsg)
        }

        return result
    }
    
    public func deleteWave(sinus_id: Int) async -> String {
        let url = "https://lovewaves.antrum-technologies.nl/api/sinus/delete"
        let parameters: [String: Any] = ["id": sinus_id]
        
        var request = RestApiHelper.createRequest(type: "PUT", url: url)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return error.localizedDescription
        }
        
        let urlSession = URLSession.shared
        var data: Data? = nil
        
        do {
            (data, _) = try await urlSession.data(for: request)
        }
        catch {
            debugPrint("Error loading \(request.url) caused error \(error) with response \((String(bytes: data!, encoding: .utf8) ?? ""))")
        }
        
        let message = String(bytes: data!, encoding: .utf8) ?? ""
        return message.replacingOccurrences(of: "\"", with: "")
    }
    
    /**
        Gathers the list of users.
     */
    public func gatherUsers(postfix: String = "") -> [SinusUserData] {
        let decoder = JSONDecoder()

        var internalUsers = [SinusUserData]()
        let sem = DispatchSemaphore.init(value: 0)

        let url = DataManager.userUrl + postfix

        let request = RestApiHelper.createRequest(type: "GET", url: url)

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, _, _ -> Void in
            do {
                internalUsers = try decoder.decode([SinusUserData].self, from: data!)
                
                    defer { sem.signal() }
            } catch {
                let returnedData = (String(bytes: data!, encoding: .utf8) ?? "")
                let errMsg = "Unable to decode points in gatherUsers: \(returnedData)"
                self.logHelper.logMsg(level: "error", message: errMsg)
                print(errMsg)
            }
        })

        task.resume()
        sem.wait()
        self.users = internalUsers
        return internalUsers
    }
    
    public func getSingleUser(user_id: Int) -> SinusUserData {
        let decoder = JSONDecoder()
        let sem = DispatchSemaphore.init(value: 0)
        let url = DataManager.userUrl + "/\(user_id)"
        
        var user: SinusUserData?
        let request = RestApiHelper.createRequest(type: "GET", url: url)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, _, _ -> Void in
            do {
                print(data)
                user = try decoder.decode(SinusUserData.self, from: data!)
                print(user)
                defer { sem.signal()
                    
                }
            } catch {
                let returnedData = (String(bytes: data!, encoding: .utf8) ?? "")
                let errMsg = "Unable to decode points in gatherUsers: \(returnedData)"
                self.logHelper.logMsg(level: "error", message: errMsg)
                print(errMsg)
            }
        })

        task.resume()
        sem.wait()
        
        return user!
    }

    /**
        Retrieves the Sinus data for a single user.
     */
    public func gatherSingleData(user: SinusUserData) -> SinusData {
        let decoder = JSONDecoder()
        var points = [GraphDataPoint]()
        let request = RestApiHelper.createRequest(type: "GET", url: DataManager.dataUrl + String(user.id))

        let data = RestApiHelper.perfomRestCall(request: request)
        if data != nil {
            do {
                points = try decoder.decode([GraphDataPoint].self, from: data!)
            } catch {
                let returnedData = (String(bytes: data!, encoding: .utf8) ?? "")
                let errMsg = "Unable to decode points in gatherSingleData: \(returnedData)"
                self.logHelper.logMsg(level: "error", message: errMsg)
                print(errMsg)
            }
        }

        var values = [Int]()
        var labels = [String]()
        var descriptions = [String]()
        points.forEach { point in
            values.append(point.value)
            labels.append(point.date)
            descriptions.append(point.description ?? "No comment")
        }

        return SinusData(id: user.id, values: values, labels: labels, descriptions: descriptions, sinusName: user.name, sinusTarget: user.date_name)
    }
}
