//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 29/3/2564 BE.
//

import Foundation

extension Pam {
    class StandardEvent {
        struct PageView: PamEvent {
            
            let pageURL:String?
            
            func getPayload() -> [String : Any] {
                return [:]
            }
            
            func getEvent() -> String {
                return ""
            }
        }
    }
}
