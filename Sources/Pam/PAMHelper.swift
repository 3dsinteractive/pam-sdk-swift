//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 29/3/2564 BE.
//

import Foundation


class PAMHelper {
    static func prettify(dict: [String: Any]) -> String {
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        return String(data: jsonData, encoding: .utf8) ?? ""
    }
    static func dateFrom(string: String?) -> Date?{
        guard let date = string else {return nil}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormatter.date(from:date)
        return dateObj
    }
}
