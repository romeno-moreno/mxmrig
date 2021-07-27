import UIKit
import WebKit
import AVFoundation

let openURLTag = "<^url^>"
let closeURLTag = "<^/url^>"

let openByLineTag = "<^by line^>"
let closeByLineTag = "<^/by line^>"

var typingDelay = 0.02
extension MainVC {
    func typingMessage(text: String, currentESC: String? = nil, originalMessage: String, completion: @escaping ()->Void) {
        if text.count == 0 ||
            isMiningTapped ||
            currentlyTypingMessage != originalMessage {
            completion()
            return
        }
        
        if text.hasPrefix(openURLTag) {
            typeURL(text: text, currentESC: currentESC, originalMessage: originalMessage, completion: completion)
            return
        }
        
        if text.hasPrefix(openByLineTag) {
            let withoutOpenTag = text.substring(from: openByLineTag.count)
            typeByLine(text: withoutOpenTag, currentESC: currentESC, originalMessage: originalMessage, completion: completion)
            return
        }
        
        var currentESC = currentESC
        if text.hasPrefix("\u{1b}"),
           let firstM = Array(text).firstIndex(of: "m") {
            currentESC = text.substring(to: firstM + 1)
            typingMessage(text: text.substring(from: firstM + 1), currentESC: currentESC, originalMessage: originalMessage, completion: completion)
        } else if let currentESC = currentESC {
            let firstChar = text.substring(to: 1)
            LoggerBridge.shared().log(currentESC + firstChar)
            if firstChar == " " {
                DispatchQueue.main.async {
                    self.typingMessage(text: text.substring(from: 1), currentESC: currentESC, originalMessage: originalMessage, completion: completion)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + typingDelay) {
                    self.typingMessage(text: text.substring(from: 1), currentESC: currentESC, originalMessage: originalMessage, completion: completion)
                }
            }
        } else {
            let firstChar = text.substring(to: 1)
            LoggerBridge.shared().log(firstChar)
            self.typingMessage(text: text.substring(from: 1), currentESC: currentESC, originalMessage: originalMessage, completion: completion)
        }
    }
    
    func typeURL(text: String, currentESC: String? = nil, originalMessage: String, completion: @escaping ()->Void) {
        let preURLText = NSAttributedString(attributedString: self.text)
        
        let withoutOpenTag = text.substring(from: openURLTag.count)
        if let closeURLTagIndex = withoutOpenTag.indexOfSubstring(closeURLTag) {
            let urlString = withoutOpenTag.substring(to: closeURLTagIndex)
            self.typingMessage(text: "\u{1b}[0\u{1b}[1;34m\(urlString)", originalMessage: originalMessage) {
                self.text = NSMutableAttributedString(attributedString: preURLText)
                if let string = LoggerBridge.shared().htmlString("\u{1b}[0\u{1b}[1;34m\(urlString)").htmlAttributedString(),
                   let url = URL(string: urlString) {
                    let attributedString = NSMutableAttributedString(attributedString: string)
                    attributedString.addAttribute(NSAttributedString.Key.link, value: url, range: NSMakeRange(0, attributedString.length))
                    if (!self.isMiningTapped) {
                        self.text.append(attributedString)
                    }
                }

                let textAfterUrl = withoutOpenTag.substring(from: closeURLTagIndex + closeURLTag.count)
                self.typingMessage(text: textAfterUrl, originalMessage: originalMessage, completion: completion)
            }
        } else {
            typingMessage(text: withoutOpenTag, currentESC: currentESC, originalMessage: originalMessage, completion: completion)
        }
    }
    
    func typeByLine(text: String, currentESC: String? = nil, originalMessage: String, completion: @escaping ()->Void) {
        if text.count == 0 ||
            isMiningTapped ||
            currentlyTypingMessage != originalMessage {
            completion()
            return
        }
        
        if let nextLineCharIndex = Array(text).firstIndex(of: "\n"),
           let closingTagIndex = text.indexOfSubstring(closeByLineTag) {
            if nextLineCharIndex < closingTagIndex {
                var line = text.substring(to: nextLineCharIndex + 1)
                if let currentESC = currentESC {
                    line = currentESC + line
                }
                LoggerBridge.shared().log(line)
                DispatchQueue.main.asyncAfter(deadline: .now() + typingDelay) {
                    self.typeByLine(text: text.substring(from: nextLineCharIndex + 1), currentESC: currentESC, originalMessage: originalMessage, completion: completion)
                }
                return
            }
        }
        if let closingTagIndex = text.indexOfSubstring(closeByLineTag) {
            var line = text.substring(to: closingTagIndex)
            if let currentESC = currentESC {
                line = currentESC + line
            }
            LoggerBridge.shared().log(line)
            DispatchQueue.main.asyncAfter(deadline: .now() + typingDelay) {
                self.typingMessage(text: text.substring(from: closingTagIndex + closeByLineTag.count), currentESC: currentESC, originalMessage: originalMessage, completion: completion)
            }
        }
    }
}
