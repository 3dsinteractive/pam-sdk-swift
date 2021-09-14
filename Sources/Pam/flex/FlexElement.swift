//
//  FlexElement.swift
//  pony
//
//  Created by narongrit kanhanoi on 16/10/2562 BE.
//  Copyright Â© 2562 narongrit kanhanoi. All rights reserved.
//

import SafariServices
import Foundation
import UIKit

class FlexElement {

    var type: ElementType
    var props: [String: String] = [:]
    var parent: FlexElement?
    var child: [FlexElement] = []
    var root: FlexElement?
    var childNum: Double = 0
    private var readerViewController: PAMNotiReaderViewController?

    var hrefList: [String] = [""]

    static var _currentFlexWindow: FlexElement?

    init(type: ElementType) {
        self.type = type
    }
    func setProperty(prop: String, value: String) {
        props[prop] = value
    }
    func addChild(_ ele: FlexElement) {
        ele.parent = self
        child.append(ele)
    }

    func toActualSize(size: Double) -> Double {
        return (Double(UIScreen.main.bounds.width) * (size / 100.0))
    }

    private func findWeightSum(_ e: FlexElement) -> Double {
        let ws = e.props["weightsum"] ?? "0"
        var weightSum = 0.0
        if ws == "0" {
            e.child.forEach {
                let w = Double($0.props["weight"] ?? "1")!
                weightSum += w
            }
        } else {
            weightSum = Double(ws)!
        }
        e.props["weightsum"] = String(format: "%f", weightSum)
        return weightSum
    }

    private func findMyWeight() -> Double {
        let weight = Double(self.props["weight"] ?? "1")!
        self.props["weight"] = String(format: "%f", weight)
        return weight
    }

    func render() -> PAMNotiReaderViewController? {
        self.readerViewController = PAMNotiReaderViewController()
        self.readerViewController?.view.backgroundColor = .white

        let w = Double(UIScreen.main.bounds.width)
        let h = Double(UIScreen.main.bounds.height)

        props["width"] = "100.0"
        props["height"] = String(format: "%f", (h / w) * 100.0)

        let scroll = UIScrollView(frame: CGRect.zero )
        scroll.translatesAutoresizingMaskIntoConstraints = false

        self.readerViewController?.view.addSubview(scroll)

        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        if let rootView = readerViewController?.view {
            scroll.leadingAnchor.constraint(equalTo: rootView.leadingAnchor ).isActive = true
            scroll.trailingAnchor.constraint(equalTo: rootView.trailingAnchor ).isActive = true
            scroll.topAnchor.constraint(equalTo: rootView.topAnchor).isActive = true
            scroll.bottomAnchor.constraint(equalTo: rootView.bottomAnchor).isActive = true
        }

        scroll.addSubview(contentView)

        contentView.leadingAnchor.constraint(equalTo: scroll.leadingAnchor ).isActive = true
        contentView.trailingAnchor.constraint(equalTo: scroll.trailingAnchor ).isActive = true
        contentView.topAnchor.constraint(equalTo: scroll.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scroll.bottomAnchor).isActive = true

        contentView.widthAnchor.constraint(equalTo: scroll.widthAnchor).isActive = true
        let heightAnc = contentView.heightAnchor.constraint(equalTo: scroll.heightAnchor)
        heightAnc.isActive = true

        root = self
        renderChild(parentView: contentView)

        FlexElement._currentFlexWindow = self
        
        return readerViewController
    }

    private func renderChild(parentView: UIView) {
        var count = 0.0
        child.forEach { e in

            e.childNum = count
            count += 1.0

            if e.type == .hbox {
                let view = UIView()
                parentView.addSubview(view)

                e.applySizeAndPosition(view)
                e.applyBaseProps(view: view)

                e.renderChild(parentView: view)
            } else if e.type == .vbox {
                let view = UIView()
                parentView.addSubview(view)

                e.applySizeAndPosition(view)
                e.applyBaseProps(view: view)

                e.renderChild(parentView: view)
            } else if e.type == .label {
                let view = UITextView()
                view.font = UIFont(name: "Arial", size: 18)
                view.isScrollEnabled = true
                view.isEditable = false
                let text = e.props["text"] ?? ""
                view.text = text
                parentView.addSubview(view)

                e.applySizeAndPosition(view)
                e.applyBaseProps(view: view)
            } else if e.type == .image {
                let view = UIImageView()
                view.contentMode = .scaleAspectFill
                parentView.addSubview(view)

                view.translatesAutoresizingMaskIntoConstraints = false

                view.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
                view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
                //e.applySizeAndPosition(view)
                e.applyBaseProps(view: view)
            }

        }
    }

    private func applySizeAndPosition(_ view: UIView) {
        if let p = self.parent {
            if p.type == .hbox {
                let w = Double(p.props["width"] ?? "0")!
                let h = Double(p.props["height"] ?? "0")!

                self.props["height"] = String(format: "%f", h)

                let weight = self.findMyWeight()
                let weightSum = self.findWeightSum(p)

                let actualWidth = weight * (w / weightSum)

                var weightIndex = 0.0
                for n in p.child {
                    if n === self {
                        break
                    } else {
                        weightIndex += n.findMyWeight()
                    }
                }
                let actualX = (weightIndex * (w / weightSum))

                view.frame = CGRect(x: p.toActualSize(size: actualX),
                    y: 0,
                    width: p.toActualSize(size: actualWidth),
                    height: p.toActualSize(size: h))
            } else if p.type == .vbox {
                let w = Double(p.props["width"] ?? "0")!
                let h = Double(p.props["height"] ?? "0")!

                self.props["width"] = String(format: "%f", w)

                let weight = self.findMyWeight()
                let weightSum = self.findWeightSum(p)

                let actualHeight = weight * (h / weightSum)

                var weightIndex = 0.0
                for n in p.child {
                    if n === self {
                        break
                    } else {
                        weightIndex += n.findMyWeight()
                    }
                }
                let actualY = (weightIndex * (h / weightSum))

                view.frame = CGRect(x: 0,
                    y: p.toActualSize(size: actualY),
                    width: p.toActualSize(size: w),
                    height: p.toActualSize(size: actualHeight))

            } else if p.type == .root {
                let w = Double(p.props["width"] ?? "0")!
                let h = Double(p.props["height"] ?? "0")!

                self.props["width"] = String(format: "%f", w)
                self.props["height"] = String(format: "%f", h)

                view.frame = CGRect(x: 0, y: 0, width: p.toActualSize(size: w), height: p.toActualSize(size: h))

            }
        }
    }

    private func applyBaseProps(view: UIView) {
        if let color = props["bgcolor"] {
            view.backgroundColor = color.toUIColor()
        }

        if let label = view as? UITextView {
            if let align = props["align"] {
                if align == "center" {
                    label.textAlignment = .center
                } else if align == "left" {
                    label.textAlignment = .left
                } else if align == "right" {
                    label.textAlignment = .right
                }
            }

            if let textcolor = props["textcolor"] {
                label.textColor = textcolor.toUIColor()
            }
        }

        if let imageView = view as? UIImageView {
            if let src = props["src"] {
                if src.hasPrefix("http") {
                    if let url = URL(string: src) {
                        DispatchQueue.global(qos: .userInitiated).async {
                            URLSession(configuration: .default).dataTask(with: url) { data, _, _ in
                                if let data = data {
                                    DispatchQueue.main.sync {
                                        imageView.image = UIImage(data: data)
                                        let w = imageView.image?.size.width ?? 0
                                        let h = imageView.image?.size.height ?? 0

                                        let scale = UIScreen.main.bounds.width/w

                                        imageView.frame = CGRect(x: 0, y: 0,
                                                                 width: UIScreen.main.bounds.width,
                                                                 height: h*scale)

                                        imageView.translatesAutoresizingMaskIntoConstraints = false

                                        imageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
                                        imageView.heightAnchor.constraint(equalToConstant: h*scale).isActive = true

                                        if let superView = imageView.superview {
                                            superView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
                                            superView.heightAnchor.constraint(equalToConstant: h*scale).isActive = true
                                        }

                                    }
                                }
                            }.resume()
                        }
                    }
                }
            }
        }

        if let href = props["href"] {
            hrefList.append(href)
            view.tag = hrefList.count - 1

            let gesture = UITapGestureRecognizer(target: self, action: #selector(onTapView))
            view.addGestureRecognizer(gesture)
            view.isUserInteractionEnabled = true
        }
    }

    @objc func onTapView(sender: UITapGestureRecognizer) {
        if let tag = sender.view?.tag {
            let link = hrefList[tag]
            if let listener = root?.readerViewController?.clickURLListener {
                listener(link)
            }
        }
    }

}


enum ElementType {
    case label
    case image
    case vbox
    case hbox
    case root
}

extension String {
    func toUIColor () -> UIColor {
        var cString: String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }
        if cString.count == 6 {
            cString += "FF"
        } else if cString.count < 6 || cString.count > 8 {
            return UIColor.gray
        }
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        let red = CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
        let gr = CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0
        let bl = CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0
        let al = CGFloat(rgbValue & 0x000000FF) / 255.0
        return UIColor(red: red, green: gr, blue: bl, alpha: al)
        }
    }
