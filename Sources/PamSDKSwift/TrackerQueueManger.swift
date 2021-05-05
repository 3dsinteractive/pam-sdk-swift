//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 29/3/2564 BE.
//

import Foundation

class TrackerQueueManger {
    typealias QueueCallback = (TrackQueue) -> Void
    
    private var queue = Array<TrackQueue>()
    var onQueueStart: QueueCallback?
    
    var processing = false
    
    func enqueue(track: TrackQueue) {
        queue.append(track)
        if !processing {
            next()
        }
    }
    
    func next(){
        if queue.count > 0 {
            processing = true
            let track = queue.remove(at: 0)
            onQueueStart?(track)
        }else{
            processing = false
        }
    }
    
}

