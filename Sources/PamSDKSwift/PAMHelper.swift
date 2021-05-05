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
}
