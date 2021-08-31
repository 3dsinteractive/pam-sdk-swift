//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 29/3/2564 BE.
//

import Foundation

protocol PamEvent{
    func getEvent() -> String
    func getPayload() -> [String: Any]
}
