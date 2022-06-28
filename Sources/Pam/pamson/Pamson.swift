//
//  Pamson.swift
//  test
//
//  Created by narongrit kanhanoi on 30/6/2564 BE.
//

import UIKit

public class Element: CustomStringConvertible{
    let type:String
    var prop:[String: String] = [:]
    var child:[Element] = []
    
    init(type: String){
        self.type = type
    }
    
    public var description: String {
        return "\(type)\n\(prop)\nChild: [\(child)]\n"
    }
}

public class Pamson {
    
    public static func parse(_ psmson: String) -> Element? {
        var buffer = ""
        var element: Element?
        var lastElement: Element?
        
        var tempPropName = ""
        
        for char in psmson {
            if char == "(" {
                if buffer == "root" {
                    element = Element(type: "root")
                    lastElement = element
                }else if buffer == "text"{
                    let ele = Element(type: "text")
                    lastElement = ele
                    element?.child.append(ele)
                }else if buffer == "image"{
                    let ele = Element(type: "image")
                    lastElement = ele
                    element?.child.append(ele)
                }
                
                buffer = ""
            }else if char == ")"{
                buffer = ""
            }else if char == "\"" {
                if tempPropName == "" {
                    tempPropName = buffer
                    buffer = ""
                }else{
                    lastElement?.prop[tempPropName] = buffer
                    buffer = ""
                    tempPropName = ""
                }
            }else if char != "="{
                buffer.append(char)
            }
            
        }
        return element
    }
    
    static func setConstrain(view: UIView, parent: UIView? = nil, before: UIView? = nil) {
        
        if let contentView = parent {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            if let beforeView = before {
                view.topAnchor.constraint(equalTo: beforeView.bottomAnchor, constant: 5).isActive = true
            }else if let parentView = parent{
                view.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 0).isActive = true
            }
            if view is UIImageView {
                view.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1).isActive = true
            }else{
                view.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95).isActive = true
            }
        }
        
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
    }
    
    public static func renderView(element: Element?, parent: UIView? = nil, before: UIView? = nil) -> UIView? {
        
        if element?.type == "root" {
            let scrollView = UIScrollView()
            scrollView.alwaysBounceVertical = true
            let contentView = UIView()
            
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            contentView.translatesAutoresizingMaskIntoConstraints = false
            
            parent?.addSubview(scrollView)
            scrollView.addSubview(contentView)
            
            if let parent = parent {
                scrollView.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
                scrollView.widthAnchor.constraint(equalTo: parent.widthAnchor).isActive = true
                scrollView.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
                scrollView.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
            }
            
            contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            
            var before: UIView?
            
            element?.child.forEach{
                if let v = renderView(element: $0, parent: contentView, before: before) {
                    contentView.addSubview(v)
                    setConstrain(view: v, parent: contentView, before: before)
                    before = v
                }
            }
            
            if let lastElement = contentView.subviews.last {
                lastElement.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            }
            
            return scrollView
        }else if element?.type == "text" {
            let view =  UILabel()
            if let textSize = element?.prop["size"]{
                if textSize == "title" {
                    view.font = UIFont.systemFont(ofSize: 22)
                }else if textSize == "body" {
                    view.font = UIFont.systemFont(ofSize: 16)
                }
            }
            view.text = element?.prop["text"]
            view.sizeToFit()
            return view
        }else if element?.type == "image" {
            let view = UIImageView()
            view.contentMode = .scaleAspectFit
            view.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            if let url = URL(string: element?.prop["src"] ?? ""){
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                view.image = image
                                let ratio = (parent?.frame.width ?? 1 ) / image.size.width
                            
                                let size = image.size.height * ratio
                                view.heightAnchor.constraint(equalToConstant: size).isActive = true
                            }
                        }
                    }
                }
            }
            
            return view
        }
        return nil
    }
    
    
}
