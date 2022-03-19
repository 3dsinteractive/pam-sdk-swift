//
//  File.swift
//  
//
//  Created by narongrit kanhanoi on 19/3/2565 BE.
//

import Foundation

public class PView {
    var props: [String: String] = [:]
    
    public func describe()->String{
        var r = ""
        if self is PImage {
            r += "Image\n"
        }else if self is PContainer {
            r += "Container\n"
        }else if self is PText {
            r += "TextView\n"
        }
        for (k,v) in props{
            r += "\t\(k)=\(v)\n"
        }
        return r
    }
    
    public func createView(parser: FlexParser) -> UIView {
        return UIView()
    }
    
}

public class PContainer: PView{
    var childs:[PView] = []
    func appendChild(e: PView){
        childs.append(e)
    }
    
    override public func describe()->String{
        var r = super.describe()
        for v in childs{
            r += v.describe()
        }
        return r
    }
    
    public override func createView(parser: FlexParser) -> UIView {
        let view = UIStackView()
        view.distribution = .fill
        view.axis = .vertical
        
        view.frame = parser.containerSize ??
        CGRect(x: 0, y: 0, width: 300, height: 300)
        
        for v in childs {
            let subView = v.createView(parser: parser)
            print(subView)
            view.addArrangedSubview(subView)
        }
        
        return view
    }
}

public class PImage: PView {
    override public func createView(parser: FlexParser) -> UIView {
        let view = UIImageView()
        view.backgroundColor = .red
        if let urlStr = props["src"] {
            if let url = URL(string: urlStr){
                let req = URLRequest(url: url)
                URLSession.shared.dataTask(with: req) { data, res, err in
                    if let data = data {
                        if let img = UIImage(data: data) {
                            view.image = UIImage(data: data)
                            view.frame = CGRect(x: view.frame.minX, y:  view.frame.minY, width: img.size.width, height: img.size.height)
                            
                            DispatchQueue.main.async {
                                
                                view.widthAnchor.constraint(equalToConstant: img.size.width).isActive = true
                                view.heightAnchor.constraint(equalToConstant: img.size.height).isActive = true
                            }
                        }
                    }
                }.resume()
            }
        }
        
        
        
        return view
    }
}

public class PText: PView {
    override public func createView(parser: FlexParser) -> UIView {
        let view = UILabel()
        view.numberOfLines = 3
        view.text = props["text"] ?? ""
        let size = props["size"]?.CGFloatValue() ?? 0
        view.font = UIFont.systemFont(ofSize: size)
        view.sizeToFit()
        
        view.widthAnchor.constraint(equalToConstant: view.frame.size.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        
        return view
    }
}

public enum TextSize: String{
    case body = "body"
    case title = "title"
}
public class FlexParser {
    
    public static let shared = FlexParser()
    
    var textSize: [String: Int] = [
        "body": 14,
        "title": 18
    ]
    
    var containerSize: CGRect?
    
    public func setTextSize(for name: TextSize, size: Int){
        textSize[name.rawValue] = size
    }
    
    public func getTextSize(_ name: TextSize) -> Int {
        return textSize[name.rawValue] ?? 6
    }
    
    public func parse(flex: String) -> PView? {
        let flex = removingWhitespaces(flex)
        var buffer = ""
        var root: PContainer?
        var currentElement: PView?
        
        var propName = ""
        var startProp = false
        for c in flex {
            if c == "(" {
                
                let e = createElement(type: buffer)
                if buffer == "root" {
                    root = e as? PContainer
                }else{
                    root?.appendChild(e: e)
                }
                currentElement = e
                buffer = ""
            }else if c == "=" {
                propName = buffer
                buffer = ""
            }else if c == "\"" {
                if !startProp {
                    startProp = true
                }else{
                    startProp = false
                    var _size = buffer
                    if currentElement is PText && propName == "size" {
                        let k = TextSize.init(rawValue: buffer) ?? .body
                        let size = getTextSize(k)
                        _size = String(describing:size)
                    }
                    
                    currentElement?.props[propName] = _size
                    buffer = ""
                }
            }else if c == ")" {
                currentElement = nil
                buffer = ""
            }else{
                buffer.append(c)
            }
        }
        return root
    }
    
    func createElement(type: String) -> PView {
        if type == "root" {
            return PContainer()
        }else if type == "image" {
            return PImage()
        }else if type == "text" {
            return PText()
        }
        return PView()
    }
    
    public func createView(pView: PContainer?, frame: CGRect? = nil) -> UIView? {
        containerSize = frame
        let root = pView?.createView(parser: self)
        return root
    }
    
    private func removingWhitespaces(_ str:String) -> String {
        return str.filter { s in
            if s != " " && s != "\n" {
                return true
            }
            return false
        }
    }
}

extension String {

  func CGFloatValue() -> CGFloat? {
    guard let doubleValue = Double(self) else {
      return nil
    }

    return CGFloat(doubleValue)
  }
}
