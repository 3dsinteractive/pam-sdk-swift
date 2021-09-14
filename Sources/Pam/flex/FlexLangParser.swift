//
//  File.swift
//  pony
//
//  Created by narongrit kanhanoi on 16/10/2562 BE.
//  Copyright Â© 2562 narongrit kanhanoi. All rights reserved.
//

import Foundation
import UIKit

class FlexLangParser {
    let whiteSpacaeChar = "\n\r\t "

    enum ParseState: String {
        case startView
        case endView
        case startProp
        case propValue
        case endProp
        case startDocument
        case endDocument
        case name
    }

    func minify(flex: String) -> String {
        var out = ""
        var ignoreSpace = true
        for char in flex {
            if ignoreSpace {
                var cut = false
                for white in whiteSpacaeChar {
                    if char == white {
                        cut = true
                    }
                }
                if !cut {
                    out.append(char)
                }
                if char == "\"" {
                    ignoreSpace.toggle()
                }
            } else {
                out.append(char)
                if char == "\"" {
                    ignoreSpace.toggle()
                }
            }
        }
        return out
    }

    private func addTab(_ count: Int) -> String {
        var tab = ""
        for _ in 0..<count {
            tab.append("\t")
        }
        return tab
    }

    func beautify(flex: String) -> String {
        var out = ""
        var tabCount = 0

        var buffer = ""

        var state = ParseState.startDocument

        for char in flex {
            if char == Character("(") {
                state = .startView
                out.append("\(addTab(tabCount))\(buffer)\(char)\n")
                tabCount += 1
                buffer = ""
            } else if char == Character(")") {
                state = .endView
                tabCount -= 1
                out.append("\(addTab(tabCount))\(char)\n")
            } else if char == Character("\"") {
                if state == .startProp {
                    state = .propValue
                    buffer.append("\(char)")
                } else if state == .propValue {
                    state = .endProp
                    out.append("\(addTab(tabCount))\(buffer)\(char)\n")
                    buffer = ""
                }
            } else if char == Character("=") {
                state = .startProp
                buffer.append(char)
            } else {
                if state == .propValue {
                    buffer.append(char)
                } else {
                    state = .name
                    buffer.append(char)
                }
            }
        }

        state = ParseState.endDocument

        return out
    }

    func parse(flex: String) -> FlexElement? {
        let flex = minify(flex: flex)
        var buffer = ""
        var state = ParseState.startDocument

        var renderStack: [FlexElement] = []
        var currentPropKey = ""
        var root: FlexElement?

        for char in flex {
            if char == Character("(") {
                state = .startView
                if buffer.lowercased() == "root" {
                    if renderStack.count == 0 {
                        root = FlexElement(type: .root)
                        if let r = root {
                            renderStack.append(r)
                        }
                    } else {
                        return nil
                    }
                } else if buffer.lowercased() == "vbox" {
                    let ele = FlexElement(type: .vbox)
                    ele.root = root
                    renderStack.last?.addChild(ele)
                    renderStack.append(ele)
                } else if buffer.lowercased() == "label" {
                    let ele = FlexElement(type: .label)
                    ele.root = root
                    renderStack.last?.addChild(ele)
                    renderStack.append(ele)
                } else if buffer.lowercased() == "hbox" {
                    let ele = FlexElement(type: .hbox)
                    ele.root = root
                    renderStack.last?.addChild(ele)
                    renderStack.append(ele)
                } else if buffer == "image" {
                    let ele = FlexElement(type: .image)
                    ele.root = root
                    renderStack.last?.addChild(ele)
                    renderStack.append(ele)
                }
                buffer = ""
            } else if char == Character(")") {
                state = .endView
                _ = renderStack.popLast()
            } else if char == Character("\"") {
                if state == .startProp {
                    state = .propValue
                    buffer = ""
                } else if state == .propValue {
                    state = .endProp
                    if currentPropKey != "" {
                        renderStack.last?.setProperty(prop: currentPropKey, value: buffer)
                        currentPropKey = ""
                    }
                    buffer = ""
                }
            } else if char == Character("=") {
                if state == .propValue {
                    buffer.append(char)
                } else {
                    state = .startProp
                    currentPropKey = buffer
                    buffer = ""
                }
            } else {
                if state == .propValue {
                    buffer.append(char)
                } else {
                    state = .name
                    buffer.append(char)
                }
            }
        }

        state = ParseState.endDocument

        return root
    }

    func toJson(flex: String?) -> String? {
        if let f = flex {
            let input = minify(flex: f)
            return input
        }
        return nil
    }
}
