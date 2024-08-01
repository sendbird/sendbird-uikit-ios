//
//  SBUMarkdownTransfer.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 4/29/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

protocol MarkdownItemable {
    var pattern: String { get }
    
    func matches(with original: NSAttributedString) -> [NSTextCheckingResult]?
    func replace(result: NSMutableAttributedString, original: NSAttributedString, match: NSTextCheckingResult)
}

extension MarkdownItemable {
    func matches(with original: NSAttributedString) -> [NSTextCheckingResult]? {
        guard let regex = try? NSRegularExpression(pattern: self.pattern, options: []) else { return nil }
        return regex.matches(in: original.string, options: [], range: NSRange(location: 0, length: original.length))
    }
    
    func replaceMarkdown(with original: NSAttributedString) -> NSAttributedString {
        guard let matches = self.matches(with: original) else { return original }
        
        let mutableValue = NSMutableAttributedString(attributedString: original)
        
        return matches
            .reversed()
            .reduce(into: mutableValue) { result, match in
                self.replace(result: result, original: original, match: match)
        }
    }
}

class SBUMarkdownTransfer {
    static func convert(with original: NSAttributedString?, isEnabled: Bool) -> NSAttributedString? {
        if isEnabled == false { return original }
        guard let original = original else { return nil }
        
        return Markdown.allCases.reduce(into: original) { result, markdown in
            result = markdown.item.replaceMarkdown(with: result)
        }
    }
    
    enum Markdown: CaseIterable {
        // NOTE: Case order determines markdown processing priority
        case bold
        case link
        
        var item: MarkdownItemable {
            switch self {
            case .bold: return Bold()
            case .link: return Link()
            }
        }
    }
}

extension SBUMarkdownTransfer.Markdown {
    struct Bold: MarkdownItemable {
        var pattern: String = "\\*\\*(.*?)\\*\\*"
        
        func replace(
            result: NSMutableAttributedString,
            original: NSAttributedString,
            match: NSTextCheckingResult
        ) {
            let range = match.range(at: 1)
            let boldText = (original.string as NSString).substring(with: range)
            result.replaceCharacters(in: match.range, with: boldText)
            result.addBoldAttribute(at: NSRange(location: match.range.location, length: boldText.utf16.count))
        }
    }
}

extension SBUMarkdownTransfer.Markdown {
    struct Link: MarkdownItemable {
        var pattern: String = "\\[([^\\[]+)\\]\\(([^\\)]+)\\)"
        
        func replace(
            result: NSMutableAttributedString,
            original: NSAttributedString,
            match: NSTextCheckingResult
        ) {
            let textRange = match.range(at: 1)
            let urlRange = match.range(at: 2)
            let urlString = (original.string as NSString).substring(with: urlRange)
            let linkText = (original.string as NSString).substring(with: textRange)
            
            result.replaceCharacters(in: match.range, with: linkText)
            let newRange = NSRange(location: match.range.location, length: linkText.utf16.count)
            result.addAttribute(.link, value: urlString, range: newRange)
            result.addBoldAttribute(at: newRange)
            result.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: newRange)
        }
    }
}

extension NSMutableAttributedString {
    func addBoldAttribute(at range: NSRange) {
        if range.length == 0, range.location == 0 { return }
        if self.string.isEmpty == true { return }
            
        let font: UIFont = self.attribute(.font, at: range.location, effectiveRange: nil) as? UIFont ??
        UIFont.systemFont(ofSize: UIFont.systemFontSize)
        
        let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) ??
        UIFont.boldSystemFont(ofSize: font.pointSize).fontDescriptor
        
        let bold = UIFont(descriptor: descriptor, size: font.pointSize)
        
        self.addAttribute(.font, value: bold, range: range)
    }
}
