//
//  LoginModel.swift
//  SinuS
//
//  Created by Loe Hendriks on 07/04/2023.
//

import Foundation
import SwiftKeychainWrapper

class AuthenticationModel: ObservableObject {
    let retrievable: RestRetrievable
    private let logHelper = LogHelper()
    
    init(retrievable: RestRetrievable) {
        self.retrievable = retrievable
    }
    
    public func register(
            name: String,
            email: String,
            password: String,
            confirmPassword: String) async throws -> AuthenticationResult? {
           let registerUrl = "https://lovewaves.antrum-technologies.nl/api/register?"
           let parameters: [String: Any] = [
               "name": name, "email": email, "password": password, "confirm_password": confirmPassword]
           let decoder = JSONDecoder()
           var request = RestApiHelper.createRequest(type: "POST", url: registerUrl, auth: false)

           do {
               request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
           } catch let error {
               print(error.localizedDescription)
               throw error
           }

           var result: AuthenticationResult?
           let data = RestApiHelper.perfomRestCall(request: request)

           do {
               result = try decoder.decode(AuthenticationResult.self, from: data!)
           } catch {
               let returnedData = (String(bytes: data!, encoding: .utf8) ?? "")
               let errMsg = "Unable to register: \(returnedData)"
               self.logHelper.logMsg(level: "error", message: errMsg)
               throw AuthenticationErrors.FailedToRegister
           }

           return result
       }
    
    public func login(email: String, password: String) async throws -> AuthenticationResult? {
           let loginUrl = "https://lovewaves.antrum-technologies.nl/api/login?"
           let parameters: [String: Any] = ["email": email, "password": password]
           let decoder = JSONDecoder()
           var request = RestApiHelper.createRequest(type: "POST", url: loginUrl, auth: false)

           do {
               request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
           } catch let error {
               print(error.localizedDescription)
               throw error
           }

           var result: AuthenticationResult?
           let data = RestApiHelper.perfomRestCall(request: request)

           do {
               result = try decoder.decode(AuthenticationResult.self, from: data!)
           } catch {
               let returnedData = (String(bytes: data!, encoding: .utf8) ?? "")
               let errMsg = "Unable to login: \(returnedData)"
               self.logHelper.logMsg(level: "error", message: errMsg)
               throw AuthenticationErrors.FailedToLogin
           }

           return result
       }
    
    public func forgotPassword(email: String) async throws -> AuthenticationResult? {
            let loginUrl = "https://lovewaves.antrum-technologies.nl/api/forgot-password"
            let parameters: [String: Any] = ["email": email]
            let decoder = JSONDecoder()
            var request = RestApiHelper.createRequest(type: "POST", url: loginUrl, auth: false)

            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
                throw error
            }

            var result: AuthenticationResult?
            let data = RestApiHelper.perfomRestCall(request: request)

            do {
                result = try decoder.decode(AuthenticationResult.self, from: data!)
            } catch {
                let returnedData = (String(bytes: data!, encoding: .utf8) ?? "")
                let errMsg = "Unable to process forgot password request: \(returnedData)"
                self.logHelper.logMsg(level: "error", message: errMsg)
                throw AuthenticationErrors.FailedToResetPassword
            }

            return result
        }

        public func resetPassword(token: String, email: String, password: String, confirmPassword: String) async throws -> AuthenticationResult? {
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
                throw error
            }

            var result: AuthenticationResult?
            let data = RestApiHelper.perfomRestCall(request: request)

            do {
                result = try decoder.decode(AuthenticationResult.self, from: data!)
            } catch {
                let returnedData = (String(bytes: data!, encoding: .utf8) ?? "")
                let errMsg = "Unable to reset password: \(returnedData)"
                self.logHelper.logMsg(level: "error", message: errMsg)
                throw AuthenticationErrors.FailedToResetPassword
            }

            return result
        }

        public func isTokenValid() async -> Bool {
            let url = "https://lovewaves.antrum-technologies.nl/api/user"
            let decoder = JSONDecoder()
            let request = RestApiHelper.createRequest(type: "GET", url: url, auth: true)
            let data = RestApiHelper.perfomRestCall(request: request)

            do {
                _ = try decoder.decode(UserData.self, from: data!)
                return true
            } catch {
                print("Error info: \(error)")
                return false
            }
        }
    
    enum AuthenticationErrors: Error {
        case FailedToLogin, FailedToRegister, FailedToResetPassword
    }
}
