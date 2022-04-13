import Foundation

class NetworkController {
    
    enum method {
        case post
        case get
    }
    static let defaultError = CustomError("Couldn't load data")
    
    static func logNewLaunchAndGetMessage(
        appVersion: String,
        completion: @escaping (
            _ message: String?,
            _ error: Error?
        ) -> Void
    ) {
        request(
            method: .post,
            endpoint: "/api/launch",
            params: [
                "appVersion": appVersion
            ]
        ) { (result, error) in
            if let message = result["message"] as? String {
                completion(message, nil)
            } else {
                completion(nil, error ?? defaultError)
            }
        }
    }
    
    static func request(
        method: NetworkController.method,
        endpoint: String,
        params:[String: Any],
        completion: @escaping ([String: Any], Error?) -> Void) {
        
        let defaultError = {
            completion([:], CustomError.error("Can't connect to the server. Please, try again later"))
        }
        
        let urlString = AppConfig.endpoint + endpoint
        guard let url = URL(string: urlString) else {
            defaultError()
            return
        }
        
        var request = URLRequest(url: url)
        if method == .post {
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                let jsonData = try JSONSerialization.data(
                  withJSONObject: params,
                  options: .prettyPrinted
                )
                request.httpBody = jsonData
            } catch {
                defaultError()
                return
            }
        } else if method == .get {
            request.httpMethod = "GET"
        }

        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let error = error {
                completion([:], error)
            } else if let data = data {
                do {
                    guard let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        defaultError()
                        return
                    }
                    if let error = dict["error"] as? String {
                        completion([:], CustomError.error(error))
                    } else {
                        completion(dict, nil)
                    }
                } catch {
                    defaultError()
                }
            } else {
                defaultError()
            }
        }
        
        task.resume()
    }
}
