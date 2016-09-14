//
//  Copyright 2016 Lionheart Software LLC
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//

import UIKit

public enum VariableNamingFormat {
    case camelCase
    case underscores
    case pascalCase
}

public protocol LHSStringType {
    /**
     Conforming types must provide a getter for the length of the string.
     
     - returns: An `Int` representing the "length" of the string (understood that this can differ based on encoding).
     - author: Daniel Loewenherz
     - copyright: ©2016 Lionheart Software LLC
     - date: February 17, 2016
     */
    var length: Int { get }

    /**
     Conforming types must provide a method to get the full range of the string.
     
     - returns: An `NSRange` representing the entire string.
     - author: Daniel Loewenherz
     - copyright: ©2016 Lionheart Software LLC
     - date: February 17, 2016
     */
    func range() -> NSRange

    func stringByLowercasingFirstLetter() -> String
    func stringByUppercasingFirstLetter() -> String
    func stringByTrimmingString(_ string: String) -> String
    func stringByReplacingSpacesWithDashes() -> String
    func stringByConvertingToNamingFormat(_ naming: VariableNamingFormat) -> String
}

public protocol LHSURLStringType {
    func URLEncodedString() -> String?
}

extension String: LHSStringType, LHSURLStringType {}
extension NSString: LHSStringType {}
extension NSAttributedString: LHSStringType {}

public extension String {
    /**
     Returns an `NSRange` indicating the length of the `String`.
     
     - returns: An `NSRange`
     - author: Daniel Loewenherz
     - copyright: ©2016 Lionheart Software LLC
     - date: February 17, 2016
     */
    func range() -> NSRange {
        return NSMakeRange(0, characters.count)
    }

    func toRange(_ range: NSRange) -> Range<String.Index> {
        let start = characters.index(startIndex, offsetBy: range.location)
        let end = characters.index(start, offsetBy: range.length)

        return start..<end
    }

    var length: Int {
        return NSString(string: self).length
    }

    mutating func trim(_ string: String) {
        self = self.stringByTrimmingString(string)
    }

    mutating func URLEncode() {
        if let string = URLEncodedString() {
            self = string
        }
    }

    mutating func replaceSpacesWithDashes() {
        self = stringByReplacingSpacesWithDashes()
    }

    mutating func replaceCapitalsWithUnderscores() {
        self = stringByConvertingToNamingFormat(.underscores)
    }

    func stringByLowercasingFirstLetter() -> String {
        let start = characters.index(after: startIndex)
        return substring(to: start).lowercased() + substring(with: start..<endIndex)
    }

    func stringByUppercasingFirstLetter() -> String {
        let start = characters.index(after: startIndex)
        return substring(to: start).uppercased() + substring(with: start..<endIndex)
    }

    func stringByTrimmingString(_ string: String) -> String {
        return self.trimmingCharacters(in: CharacterSet(charactersIn: string))
    }

    func URLEncodedString() -> String? {
        if let string = addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            return string
        }
        else {
            return nil
        }
    }

    func stringByReplacingSpacesWithDashes() -> String {
        let regexOptions = NSRegularExpression.Options()
        let regex = try! NSRegularExpression(pattern: "[ ]", options: regexOptions)
        return regex.stringByReplacingMatches(in: self, options: NSRegularExpression.MatchingOptions(), range: range(), withTemplate: "-").lowercased() as String
    }

    
    func stringByConvertingToNamingFormat(_ naming: VariableNamingFormat) -> String {
        switch naming {
        case .underscores:
            let regex = try! NSRegularExpression(pattern: "([A-Z]+)", options: NSRegularExpression.Options())
            let string = NSMutableString(string: self)
            regex.replaceMatches(in: string, options: NSRegularExpression.MatchingOptions(), range: range(), withTemplate: "_$0")
            let newString = string.stringByTrimmingString("_").lowercased()
            if hasPrefix("_") {
                return "_" + newString
            }
            else {
                return newString
            }

        case .camelCase:
            fatalError()

        case .pascalCase:
            var uppercaseNextCharacter = false
            var result = ""
            for character in characters {
                if character == "_" {
                    uppercaseNextCharacter = true
                }
                else {
                    if uppercaseNextCharacter {
                        result += String(character).uppercased()
                        uppercaseNextCharacter = false
                    }
                    else {
                        character.write(to: &result)
                    }
                }
            }
            return result
        }
    }

    mutating func convertToNamingFormat(_ naming: VariableNamingFormat) {
        self = stringByConvertingToNamingFormat(naming)
    }

    func isComposedOfCharactersInSet(_ characterSet: CharacterSet) -> Bool {
        for scalar in unicodeScalars {
            if !characterSet.contains(UnicodeScalar(scalar.value)!) {
                return false
            }
        }

        return true
    }
}

public extension NSString {
    /**
     Returns an `NSRange` indicating the length of the `NSString`.
     
     - returns: An `NSRange`
     - author: Daniel Loewenherz
     - copyright: ©2016 Lionheart Software LLC
     - date: February 17, 2016
     */
    func range() -> NSRange {
        return String(self).range()
    }
    
    func slugify() {
        return String(self).slugify()
    }

    func stringByLowercasingFirstLetter() -> String {
        return String(self).stringByLowercasingFirstLetter()
    }

    func stringByUppercasingFirstLetter() -> String {
        return String(self).stringByLowercasingFirstLetter()
    }

    func stringByReplacingSpacesWithDashes() -> String {
        return String(self).stringByReplacingSpacesWithDashes()
    }

    func stringByConvertingToNamingFormat(_ naming: VariableNamingFormat) -> String {
        return String(self).stringByConvertingToNamingFormat(naming)
    }

    func stringByTrimmingString(_ string: String) -> String {
        return String(self).stringByTrimmingString(string)
    }
}

public extension NSAttributedString {
    /**
     Returns an `NSRange` indicating the length of the `NSAttributedString`.
     
     - returns: An `NSRange`
     - author: Daniel Loewenherz
     - copyright: ©2016 Lionheart Software LLC
     - date: February 17, 2016
     */
    func range() -> NSRange {
        return String(describing: self).range()
    }

    func stringByLowercasingFirstLetter() -> String {
        return String(describing: self).stringByLowercasingFirstLetter()
    }

    func stringByUppercasingFirstLetter() -> String {
        return String(describing: self).stringByLowercasingFirstLetter()
    }

    func stringByReplacingSpacesWithDashes() -> String {
        return String(describing: self).stringByReplacingSpacesWithDashes()
    }

    func stringByConvertingToNamingFormat(_ naming: VariableNamingFormat) -> String {
        return String(describing: self).stringByConvertingToNamingFormat(.underscores)
    }

    func stringByTrimmingString(_ string: String) -> String {
        return String(describing: self).stringByTrimmingString(string)
    }
}

public extension NSMutableAttributedString {
    func addStringWithAttributes(_ string: String, attributes: [String: AnyObject]) {
        let attributedString = NSAttributedString(string: string, attributes: attributes)
        append(attributedString)
    }
    
    func addAttribute(_ name: String, value: AnyObject) {
        addAttribute(name, value: value, range: range())
    }
    
    func addAttributes(_ attributes: [String: AnyObject]) {
        addAttributes(attributes, range: range())
    }
    
    func removeAttribute(_ name: String) {
        removeAttribute(name, range: range())
    }
}
