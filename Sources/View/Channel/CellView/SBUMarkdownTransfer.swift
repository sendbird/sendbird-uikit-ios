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
        
        /// `pattern` 정규식과 같은 위치와 묶음을 돌려준다.
        ///
        /// 정규식은 `)` 가 없으면 `[` 마다 주소 부분이 글 끝까지 훑어, `[a](` 가 반복되는 긴 글에서 시간이 글 길이의 제곱으로 늘었다.
        /// 여기서는 다음 `)` 위치를 뒤에서부터 한 번 계산해 두고 앞에서부터 한 번 훑는다.
        /// - 글자 부분 `[^\[]+` 는 다음 `[` 를 넘지 않는다. 그래서 `[` 마다 볼 `](` 후보가 서로 겹치지 않는다.
        /// - 정규식은 글자 부분을 가장 길게 잡으므로, 후보 중 주소가 성립하는 가장 뒤의 `](` 를 고른다.
        /// - 주소 부분 `[^\)]+` 는 `](` 바로 뒤부터 처음 나오는 `)` 앞까지이고 한 글자 이상이어야 한다. 줄바꿈도 넘는다.
        func matches(with original: NSAttributedString) -> [NSTextCheckingResult]? {
            guard let regex = try? NSRegularExpression(pattern: self.pattern, options: []) else { return nil }
            let text = original.string as NSString
            let count = text.length
            let bracket = UInt16(UInt8(ascii: "[")), close = UInt16(UInt8(ascii: "]"))
            let open = UInt16(UInt8(ascii: "(")), paren = UInt16(UInt8(ascii: ")"))
            var units = [UInt16](repeating: 0, count: count)
            if count > 0 { text.getCharacters(&units, range: NSRange(location: 0, length: count)) }

            // nextParen[i]: i 부터 처음 나오는 ) 위치. 없으면 nil.
            var nextParen = [Int?](repeating: nil, count: count + 1)
            var position = count - 1
            while position >= 0 {
                nextParen[position] = units[position] == paren ? position : nextParen[position + 1]
                position -= 1
            }

            var results: [NSTextCheckingResult] = []
            var index = 0
            while index < count {
                guard units[index] == bracket else {
                    index += 1
                    continue
                }
                // 글자 부분은 index + 1 부터 다음 [ 앞까지. 그 안에서 한 글자 이상 뒤에 오는 ]( 가 후보다.
                var segmentEnd = index + 1
                var candidates: [Int] = []
                while segmentEnd < count, units[segmentEnd] != bracket {
                    if segmentEnd >= index + 2, units[segmentEnd] == close,
                       segmentEnd + 1 < count, units[segmentEnd + 1] == open {
                        candidates.append(segmentEnd)
                    }
                    segmentEnd += 1
                }
                let found = candidates.reversed().lazy.compactMap { textEnd -> (Int, Int)? in
                    let urlStart = textEnd + 2
                    guard urlStart < count, let urlEnd = nextParen[urlStart], urlEnd > urlStart else { return nil }
                    return (textEnd, urlEnd)
                }.first
                guard let (textEnd, urlEnd) = found else {
                    // 이 [ 에서는 링크가 안 된다. 정규식처럼 다음 글자부터 다시 찾는다(다음 후보는 다음 [ 다).
                    index = segmentEnd
                    continue
                }
                var ranges = [
                    NSRange(location: index, length: urlEnd + 1 - index),
                    NSRange(location: index + 1, length: textEnd - index - 1),
                    NSRange(location: textEnd + 2, length: urlEnd - textEnd - 2),
                ]
                results.append(NSTextCheckingResult.regularExpressionCheckingResult(
                    ranges: &ranges,
                    count: ranges.count,
                    regularExpression: regex
                ))
                index = urlEnd + 1
            }
            return results
        }
        
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
            result.addAttribute(.link, value: urlString.asURLEncoded, range: newRange)
            result.addBoldAttribute(at: newRange)
            result.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: newRange)
        }
    }
}

extension NSMutableAttributedString {
    func addBoldAttribute(at range: NSRange) {
        if range.length == 0 || range.location == 0 { return }
        if self.string.isEmpty == true { return }
        guard range.location < self.length else {
            return
        }
        let font: UIFont = self.attribute(.font, at: range.location, effectiveRange: nil) as? UIFont ??
        UIFont.systemFont(ofSize: UIFont.systemFontSize)
        
        let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) ??
        UIFont.boldSystemFont(ofSize: font.pointSize).fontDescriptor
        
        let bold = UIFont(descriptor: descriptor, size: font.pointSize)
        
        self.addAttribute(.font, value: bold, range: range)
    }
}
