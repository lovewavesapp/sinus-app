//
//  DataGatherer.swift
//  SinuS
//
//  Created by Loe Hendriks on 06/09/2022.
//

import Foundation

/**
    Internal struct to hold data/date's
 */
private struct GraphDataPoint : Codable {
    let date: String
    let value: Int
}

/**
    Class responsible for storing and retrieve data to and from the backend.
 */
public class DataManager {
    // endpoints
    private static var userUrl = "https://www.lukassinus2.vanbroeckhuijsenvof.nl/api/sinus"
    private static var dataUrl = "https://www.lukassinus2.vanbroeckhuijsenvof.nl/api/sinusvalue/"
    
    private var users = [SinusUserData]()
    
    /**
        Creates a new user.
     */
    public func AddUser(user: String, target: String) {
        let sem = DispatchSemaphore.init(value: 0)
        let parameters: [String: Any] = ["name": user, "date_name": target]
        
        var request = URLRequest(url: URL(string: DataManager.userUrl)!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            defer { sem.signal() }
            print(response as Any)
        })
        
        task.resume()
        sem.wait()
    }
    
    /**
        Updates the graphs for a user by adding a new point.
     */
    public func SendData(data: SinusUpdate) {
        let sem = DispatchSemaphore.init(value: 0)
        if let user = self.users.first(where: { user in
            return user.name == data.name
        }) {
            let url = "https://lukassinus2.vanbroeckhuijsenvof.nl/api/sinusvalue"
            
            let formatter = DateFormatter()
            formatter.dateFormat = "y-MM-d"
            
            
            
            let parameters: [String: Any] = ["sinus_id": user.id, "date": formatter.string(from: data.date), "value": data.value]
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            } catch let error {
                print(error.localizedDescription)
                return
            }
            
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                defer { sem.signal() }
                print(response as Any)
            })
            
            task.resume()
            sem.wait()
        }
    }
    
    
    /**
        Gathers the list of users.
     */
    public func GatherUsers() -> [SinusUserData] {
        let decoder = JSONDecoder()
        
        var internalUsers = [SinusUserData]()
        let sem = DispatchSemaphore.init(value: 0)
        
        var request = URLRequest(url: URL(string: DataManager.userUrl)!)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                defer { sem.signal() }
                internalUsers = try decoder.decode([SinusUserData].self, from: data!)
            } catch {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
        sem.wait()
        
        return internalUsers
    }
    
    
    /**
        Retrieves the Sinus data for a single user.
     */
    public func GatherSingleData(user: SinusUserData) -> SinusData {
        let decoder = JSONDecoder()
        let url = URL(string: DataManager.dataUrl + String(user.id))
        var points = [GraphDataPoint]()
        let sem = DispatchSemaphore.init(value: 0)
        
        var graphDataRequest = URLRequest(url: url!)
        graphDataRequest.httpMethod = "GET"
        graphDataRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: graphDataRequest, completionHandler: { data2, response2, error2 -> Void in
            do {
                defer { sem.signal() }
                points = try decoder.decode([GraphDataPoint].self, from: data2!)
            } catch {
                print(error2!.localizedDescription)
            }
        })
        
        task.resume()
        sem.wait()
        
        var values = [Int]()
        var labels = [String]()
        points.forEach { p in
            values.append(p.value)
            labels.append(p.date)
        }
        
        return SinusData(id: user.id, values: values, labels: labels, sinusName: user.name, sinusTarget: user.date_name)
    }
}
