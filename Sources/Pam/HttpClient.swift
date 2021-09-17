//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 29/3/2564 BE.
//

import Foundation

enum HttpClient {
    typealias OnSuccess = ([String: Any]?) -> Void
    typealias OnSuccessData = (Data?) -> Void

    static func get(url: String, queryString: [String: String]?, headers: [String: String]?, onSuccess: OnSuccess?) {
        
        getReturnData(url: url, queryString: queryString, headers: headers) { data in
            guard let data = data else {return}
            let resultDictionay = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            onSuccess?(resultDictionay)
        }

    }
    
    static func post(url: String, queryString: [String: String]?, headers: [String: String]?, json: [String: Any]?, onSuccess: OnSuccess?) {
        guard var url = URLComponents(string: url) else { return }
        url.queryItems = []
        queryString?.forEach {
            url.queryItems?.append(URLQueryItem(name: $0.key, value: $0.value))
        }

        guard let reqURL = url.url else { return }

        var request = URLRequest(url: reqURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        headers?.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }

        if let json = json {
            request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [])
        }

        if Pam.shared.isEnableLog {
            print("🛺 Request POST: ", request.curlString )
        }
        let session = URLSession.shared
        session.dataTask(with: request) { data, _, error in
            if error == nil, let data = data {
                
                if Pam.shared.isEnableLog {
                    print("🛺 PAM", String(data: data, encoding: .utf8) ?? "" )
                }
                
                let resultDictionay = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                onSuccess?(resultDictionay)
            }
        }.resume()
    }
    
    static func getReturnData(url: String, queryString: [String: String]?, headers: [String: String]?, onSuccess: OnSuccessData?) {
        
        guard var url = URLComponents(string: url) else { return }
        url.queryItems = []
        queryString?.forEach {
            url.queryItems?.append(URLQueryItem(name: $0.key, value: $0.value))
        }

        guard let reqURL = url.url else { return }

        var request = URLRequest(url: reqURL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        headers?.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }

            
        if Pam.shared.isEnableLog {
            print("🛺 Request GET: ", request.curlString )
        }
        
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, _, error in
            if error == nil, let data = data {
                
                if Pam.shared.isEnableLog {
                    if let stringResult = String(data: data, encoding: .utf8) {
                        print("🛺 PAM", stringResult )
                    }
                }
                
                onSuccess?(data)
            }
        }.resume()
    }
}

extension URLRequest {

    /**
     Returns a cURL command representation of this URL request.
     */
    public var curlString: String {
        guard let url = url else { return "" }
        var baseCommand = #"curl "\#(url.absoluteString)""#

        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]

        if let method = httpMethod, method != "GET" && method != "HEAD" {
            command.append("-X \(method)")
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }

        if let data = httpBody, let body = String(data: data, encoding: .utf8) {
            command.append("-d '\(body)'")
        }

        return command.joined(separator: " \\\n\t")
    }

    init?(curlString: String) {
        return nil
    }

}
