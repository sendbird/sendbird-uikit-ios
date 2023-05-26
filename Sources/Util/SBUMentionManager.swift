//
//  SBUMentionManager.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/04/11.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

public protocol SBUMentionManagerDelegate: AnyObject {
    /// Called when the suggestedMention users was updated.
    /// - Parameters:
    ///   - manager: `SBUMentionManager` object.
    ///   - users: suggested mention users. If there are no users to suggest, the object becomes a empty array.
    func mentionManager(
        _ manager: SBUMentionManager,
        didChangeSuggestedMention users: [SBUUser],
        filteredText: String?,
        isTriggered: Bool
    )
    
    /// Called when new mentions was inserted to the `textView`.
    /// - Parameters:
    ///   - manager: `SBUMentionManager` object.
    ///   - textView: `UITextView` object that uses the `manager` for mention feature.
    func mentionManager(
        _ manager: SBUMentionManager,
        didInsertMentionsTo textView: UITextView
    )
    
    /// Called when it needs to load the suggested mentions with `keyword`.
    /// - Parameters:
    ///   - manager: `SBUMentionManager` object.
    ///   - filterText: The text that is used as filter.
    func mentionManager(_ manager: SBUMentionManager, shouldLoadSuggestedMentions filterText: String)
}

public protocol SBUMentionManagerDataSource: AnyObject {
    /// Asks to data source to return the suggested mention with `filterText`
    /// - Returns: The suggested mentions as array of `SBUUser`
    func mentionManager(_ manager: SBUMentionManager, suggestedMentionUsersWith filterText: String) -> [SBUUser]
}

/// The class that manages mentions from `UITextView` instance.
public class SBUMentionManager: NSObject {

    // MARK: - Public properties
    /// The current `SBUMention` list. (*read-only*).
    /// - NOTE: The `SBUMention` contains the range of mentioned text and a mentioned user
    public private(set) var mentionedList: [SBUMention] = []

    /// The trigger keyword to start a mention. The value is from `SBUStringSet.Mention.Trigger_Key` which is `"@"`.
    public let trigger: String = SBUGlobals.userMentionConfig?.trigger ?? SBUStringSet.Mention.Trigger_Key

    /// Text attributes to be applied to all text excluding mentions as default.
    public var defaultTextAttributes: [NSAttributedString.Key: Any] = [:]

    /// Text attributes to be applied to the mentions
    public var mentionTextAttributes: [NSAttributedString.Key: Any] = [:]
    
    // MARK: - Private properties
    weak var delegate: SBUMentionManagerDelegate?
    weak var dataSource: SBUMentionManagerDataSource?
    
    /// Range of mention currently being edited.
    private var currentMentionRange = NSRange(location: NSNotFound, length: 0)

    /// Text for filtering
    private var filterText: String = ""
    private var prevFilterText: String = ""

    /// Whether or not a mention is currently being edited
    private var isMentionEnabled = false

    // MARK: - Life cycle
    public override init() {
        super.init()
    }
    
    /// Initializes and configures the manager to allows for customization of text attributes for default text and mentions
    /// - Parameters:
    ///   - delegate: `SBUMentionManagerDelegate` object
    ///   - dataSource: `SBUMentionManagerDataSource` object
    ///   - defaultTextAttributes: Text attributes to be applied to all text excluding mentions as default.
    ///   - mentionTextAttributes: Text attributes to be applied to the mentions.
    public func configure(
        delegate: SBUMentionManagerDelegate? = nil,
        dataSource: SBUMentionManagerDataSource? = nil,
        defaultTextAttributes: [NSAttributedString.Key: Any]? = nil,
        mentionTextAttributes: [NSAttributedString.Key: Any]? = nil
    ) {
        self.delegate = delegate
        self.dataSource = dataSource
        
        self.defaultTextAttributes = defaultTextAttributes ?? [:]
        self.mentionTextAttributes = mentionTextAttributes ?? [:]
    }
    
    // MARK: - Mentions
    
    /// Adds a mention to the current mention range
    /// - Parameters:
    ///   - textView: The textview to add mentioned infos.
    ///   - user: The mention to be added
    /// - Returns: `true`: Add successfully
    @discardableResult
    public func addMention(at textView: UITextView, user: SBUUser) -> Bool {
        guard currentMentionRange.location != NSNotFound else { return false }

        // [Mention List]
        
        // INFO: 추가될 멘션이 적용될 range (입력시작 위치, 입력될 nickname count(@포함) )
        let newMentionRange = NSRange(
            location: currentMentionRange.location,
            length: user.mentionedNickname().utf16.count
        )
        
        // INFO: 추가될 mention 객체
        let mentionToAdd = SBUMention(range: newMentionRange, user: user)
        
        // INFO: 추가될 멘션의 range 를 기준으로 기존 멘션리스트에 있는 멘션들의 range 를 조정
        let delimiter = SBUGlobals.userMentionConfig?.delimiter ?? " "
        let adjustedMentions = adjust(
            with: user.mentionedNickname() + delimiter,
            at: currentMentionRange
        )
        // INFO: 전체 mention 목록을 조정된 멘션 목록 + 새로운 멘션 정보로 교체
        mentionedList = adjustedMentions + [mentionToAdd]
        
        // [Attributed text]
        
        // INFO: currentMentionRange에 있는 문자열을 user 정보를 사용해서 mentionText 로 변경하고, mentionTextAttributes 가 적용된 attributedText 와 새로운 range 정보를 생성.
        let (text, selectedRange) = add(
            user: user,
            on: textView.attributedText,
            at: currentMentionRange
        )
        
        textView.attributedText = text
        textView.selectedRange = selectedRange

        self.delegate?.mentionManager(self, didInsertMentionsTo: textView)
        
        isMentionEnabled = false
        filterText = ""
        prevFilterText = ""

        self.delegate?.mentionManager(
            self,
            didChangeSuggestedMention: [],
            filteredText: nil,
            isTriggered: false
        )

        return true
    }
    
    /// Removes the provided mentions and replaces the text attributes to default on the text view.
    /// - Parameters:
    ///   - textView: The textview to remove mentioned info.
    ///   - mention: The mention to be removed
    public func clearMentions(_ mentions: [SBUMention],
                              with replaceText: String = "",
                              on textView: UITextView,
                              at range: NSRange) {
        for mention in mentions {
            // Removes mention from mentionedList
            let removedMentions = self.remove(mention)
            self.mentionedList = removedMentions
            
            // Sets defaultTextAttributes on mention's range.
            let appliedAttributes = self.apply(
                textAttributes: self.defaultTextAttributes,
                on: textView.attributedText,
                at: mention.range
            )
            
            let (text, selectedRange) = appliedAttributes
            textView.attributedText = text
            textView.selectedRange = selectedRange
        }
        
        // Removes mentioned text. If exist replacetext, replaces the text in range.
        let values: (text: NSAttributedString, selectedRange: NSRange)
        let replacedAttributedText = self.replace(
            with: replaceText,
            on: textView.attributedText,
            at: range
        )
        values = replacedAttributedText
        textView.attributedText = values.text
        textView.selectedRange = values.selectedRange
    }
    
    // MARK: - TextView handling
    
    /// When there's any changes in the `range`of mention in the `textView`, it removes the mention and replaces to the `replacementText` if needed.
    /// This function is called from `messageInputView(_:shouldChangeTextIn:replacementText:)`delegate method.
    public func shouldChangeText(on textView: UITextView,
                                 in range: NSRange,
                                 replacementText: String) -> Bool {
        textView.typingAttributes = self.defaultTextAttributes
        
        var shouldChangeText = true
        var replacementRange = range

        if let mentions = mentionBeingEdited(at: range), !mentions.isEmpty {
            if mentions.count == 1, let mention = mentions.first, range.length == 1 {
                // INFO: Removes only 1 mention by using *back space*, a keyboard input.
                self.clearMentions([mention], with: replacementText, on: textView, at: mention.range)
                replacementRange = mention.range
            } else {
                self.clearMentions(mentions, with: replacementText, on: textView, at: range)
            }
            
            shouldChangeText = false
        }
        
        let adjustedMentions = self.adjust(
            with: replacementText,
            at: replacementRange
        )
        mentionedList = adjustedMentions

        if !shouldChangeText {
            textView.delegate?.textViewDidChange?(textView)
            textView.delegate?.textViewDidChangeSelection?(textView)
        }
        
        return shouldChangeText
    }
    
    /// Checks if text selection is required to be skip
    /// - Parameter textView: `UITextView`
    /// - Returns: `true`: need to skip
    public func needToSkipSelection(_ textView: UITextView) -> Bool {
        if let mentionedRange = self.isMentionRange(with: textView.selectedRange) {
            if textView.selectedRange.length == 0 {
                var location = mentionedRange.location
                if (mentionedRange.location + mentionedRange.length / 2) > textView.selectedRange.location {
                    location = mentionedRange.location
                } else {
                    location = NSMaxRange(mentionedRange)
                }
                
                var range = textView.selectedRange
                range.location = location
                if textView.selectedRange != range {
                    textView.selectedRange = range
                }
                return true
            } else {
                var selectedRange = textView.selectedRange
                
                let startIdx = mentionedRange.location
                let endIdx = NSMaxRange(mentionedRange)
                if case startIdx...endIdx = NSMaxRange(selectedRange) {
                    // selectedRange 뒷부분이 멘션에 포함될때
                    
                    if NSMaxRange(selectedRange) > (mentionedRange.location + mentionedRange.length/2) {
                        // 선택범위가 멘션의 중간이후 -> 멘션 뒤로
                        selectedRange.length = NSMaxRange(mentionedRange) - selectedRange.location
                    } else {
                        selectedRange.length = mentionedRange.location - selectedRange.location
                    }
                } else if case startIdx...endIdx = selectedRange.location {
                    // selectedRange 앞부분이 멘션에 포함될때
                    
                    if selectedRange.location > (mentionedRange.location + mentionedRange.length/2) {
                        // 선택범위가 멘션의 중간이후 -> 멘션 뒤로
                        let remainingLength = NSMaxRange(mentionedRange) - selectedRange.location
                        selectedRange.location = NSMaxRange(mentionedRange)
                        selectedRange.length -= remainingLength
                    } else if endIdx > selectedRange.location {
                        let endLocation = NSMaxRange(selectedRange)
                        selectedRange.location = mentionedRange.location
                        selectedRange.length = endLocation - mentionedRange.location
                    }
                }
                
                textView.selectedRange = selectedRange
                return true
            }
        }
        return false
    }
    
    /// Checks the location is in mention range
    /// - Parameter location: Location to check
    /// - Returns: If the location is in the range of mention list, return detected range value.
    private func isMentionRange(with range: NSRange) -> NSRange? {
        let filteredList = mentionedList.filter {
            let startIdx = $0.range.location
            let endIdx = NSMaxRange($0.range)
            if range.length == 1 {
                if case startIdx...endIdx = range.location {
                    return true
                }
            } else {
                if case startIdx...endIdx = NSMaxRange(range) {
                    return true
                } else if case startIdx...endIdx = range.location {
                    return true
                }
            }
            return false
        }
        
        if filteredList.count > 0 {
            return filteredList.first?.range
        }
        return nil
    }
    
    /// Finds mentions from a given `range`
    public func findMentions(with range: NSRange) -> [SBUMention] {
        let filteredList = mentionedList.filter {
            NSEqualRanges($0.range, range)
        }
        return filteredList
    }
    
    // MARK: - Mentionable
    
    public func handlePendingMentionSuggestion() {
        self.prevFilterText = filterText
        
        if self.suggestedMentionUsers.count > 0 {
            self.prevFilterText = filterText
            
            self.delegate?.mentionManager(
                self,
                didChangeSuggestedMention: self.suggestedMentionUsers,
                filteredText: filterText,
                isTriggered: true
            )
        } else {
            self.delegate?.mentionManager(
                self,
                didChangeSuggestedMention: [],
                filteredText: nil,
                isTriggered: false
            )
        }
    }
    
    /// Handle the suggested mentions.  If a mention is updated, it updates `currentMentionRange`, `filterText`, and calls `mentionManager(_:didChangeSuggestedMention:filteredText:isTriggered:)` delegate method. It also calls `mentionManager(_:shouldLoadSuggestedMentions:)` delegate method  when it needs API calls.
    /// - Parameters:
    ///   - textView: The textview to be determined.
    ///   - range: selected range
    public func handleMentionSuggestion(on textView: UITextView, range: NSRange) {
        let startIndex = textView.text.startIndex
        let endIndex = textView.text.index(
            startIndex,
            offsetBy: min(NSMaxRange(range), textView.text.count)
        )
        let stringToSelectedIndex = String(textView.text[startIndex ..< endIndex])
        
        let searchRange = self.searchMentionableRange(
            with: stringToSelectedIndex,
            options: .backwards
        )

        let location = searchRange.location

        isMentionEnabled = location != NSNotFound
            ? self.isMentionEnabledAt(with: textView.text, location: location)
            : false

        if isMentionEnabled {
            var mentionString: String = ""
            let startIndex = textView.text.utf16.index(textView.text.startIndex, offsetBy: location)
            let endIndex = textView.text.utf16.index(
                startIndex,
                offsetBy: NSMaxRange(textView.selectedRange) - location
            )
            if startIndex < endIndex {
                mentionString = String(textView.text[startIndex ..< endIndex])
            }

            filterText = ""

            if !mentionString.isEmpty {
                currentMentionRange = (textView.text as NSString).range(
                    of: mentionString,
                    options: .backwards,
                    range: NSRange(location: 0, length: NSMaxRange(textView.selectedRange))
                )
                
                if mentionString.hasPrefix(self.trigger) {
                    // Supports nickname start with trigger keyword. (@@ case)
                    filterText = String(mentionString.dropFirst())
                }

                if SBUGlobals.userMentionConfig?.isCustomUserListUsed == true {
                    if self.suggestedMentionUsers(with: filterText).count > 0 {
                        self.handlePendingMentionSuggestion()
                        return
                    }
                } else {
                    if (self.prevFilterText != filterText) || (mentionString == self.trigger) {
                        self.delegate?.mentionManager(
                            self,
                            shouldLoadSuggestedMentions: filterText
                        )
                        
                        self.prevFilterText = (mentionString == self.trigger) ? self.trigger : filterText
                    }
                    return
                }
            }
        }

        self.delegate?.mentionManager(
            self,
            didChangeSuggestedMention: [],
            filteredText: nil,
            isTriggered: false
        )
    }
    
    // MARK: - User
    
    /// The suggested user list for mention with current text. *(Read-only)*
    public var suggestedMentionUsers: [SBUUser] {
        self.suggestedMentionUsers(with: filterText)
    }
    
    /// Returns the suggested mentionable user list for a specific `filterText`.
    /// - Returns: The array of `SBUUser` obejcts.
    public func suggestedMentionUsers(with filterText: String) -> [SBUUser] {
        let userList = self.dataSource?.mentionManager(self, suggestedMentionUsersWith: filterText) ?? []
        guard !userList.isEmpty, filterText != "" else { return userList }
        return userList.filter {
            $0.nickname?.lowercased().contains(filterText.lowercased()) ?? false
        }
    }
    
    /// Convert mentionedMessageTemplate to normal message with mentionedUserIds.
    ///
    /// ```
    /// mentionedMessage: "Hello @{Tez.park}, blabla."
    /// -> convertedMessage: "Hello @Tez Park, blabla.", [SBUMention]
    /// ```
    /// - Parameters:
    ///   - mentionedMessageTemplate: Mentioned message received from the server
    ///   - mentionedUsers: Mentioned users received from the server
    /// - Returns: attributedText
    public func generateMentionedMessage(
        with mentionedMessageTemplate: String,
        mentionedUsers: [SBUUser]
    ) -> NSAttributedString {
        // TODO: -> static func

        // mentionedMessage: "Hello @{Tez.park}, blabla."
        // convertedMessage: "Hello @Tez Park, blabla.", [SBUMention]
        
        var attributedText = NSMutableAttributedString(
            string: mentionedMessageTemplate,
            attributes: self.defaultTextAttributes
        )
        let regex = "[@][{](.*?)([}])"
        let mentionedIds = mentionedMessageTemplate.regexMatchingList(regex: regex)
        var replacedMessage = mentionedMessageTemplate
        
        for mentionedId in mentionedIds {
            guard let userId = mentionedId.unwrappingRegex(regex) else { continue }

            let matchedUsers = mentionedUsers.filter { $0.userId == userId }
            guard let user = matchedUsers.first else { continue }
            
            let mentionedNickname = user.mentionedNickname()
            let range = (replacedMessage as NSString).range(
                of: mentionedId,
                options: .caseInsensitive
            )

            // INFO: range에 있는 문자열을 mentionText 로 변경한 attributedText 와 교체된 range 정보를 생성.
            let textToReplace = mentionedNickname
            let replacedAttributes = replace(
                with: textToReplace,
                on: attributedText,
                at: range
            )
            let replacedAttributedText = replacedAttributes.0

            // INFO: mentionTextAttribute 를 적용할 range
            let adjustedRange = NSRange(
                location: range.location,
                length: mentionedNickname.utf16.count
            )

            // INFO: attributedText 에서 range 영역에 attributes 를 적용
            let (appliedAttributedText, _) = apply(
                textAttributes: mentionTextAttributes,
                on: replacedAttributedText,
                at: adjustedRange
            )
            
            let mention = SBUMention(range: adjustedRange, user: user)
            mentionedList = mentionedList + [mention]
            
            replacedMessage = appliedAttributedText.string
            attributedText = NSMutableAttributedString(attributedString: appliedAttributedText)
        }
        
        return attributedText
    }
    
    /// Converts normal message to mentionedMessageTemplate with mentions.
    ///
    /// ```
    /// convertedMessage: "Hello @Tez Park, blabla.", [SBUMention]
    /// -> mentionedMessage: "Hello @{Tez.park}, blabla."
    /// ```
    /// - Parameters:
    ///   - message: Message
    ///   - mentions: mention infos array
    /// - Returns: MentionedMessage for sending to server
    public func generateTemplate(with attributedText: NSAttributedString,
                                 mentions: [SBUMention]) -> String {
        // TODO: -> static func

        // client -> server
        // convertedMessage: "Hello @Tez Park, blabla.", [SBUMention]
        // mentionedMessage: "Hello @{Tez.park}, blabla."
        
        var attributedText = attributedText
        var tempMentionedList = mentionedList
        
        for i in 0..<mentions.count {
            let mention = tempMentionedList[i]
            let textToReplace = "@{" + mention.user.userId + "}"
            
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            if mention.range.location + mention.range.length > mutableAttributedText.length { continue }
            mutableAttributedText.replaceCharacters(in: mention.range, with: textToReplace)
            attributedText = mutableAttributedText
            
            let adjustedMentions = adjust(
                with: textToReplace,
                on: tempMentionedList,
                at: mention.range
            )
            tempMentionedList = adjustedMentions
        }
        
        return attributedText.string
    }
    
    /// Resets all mention regarding resources such as `mentionedList`.
    public func reset() {
        self.mentionedList = []
        self.filterText = ""
        self.currentMentionRange = NSRange(location: NSNotFound, length: 0)
        self.isMentionEnabled = false
    }
}

// MARK: - MentionsArray
extension SBUMentionManager {
    /// Adjusts the range values of the mentions in the existing mention list based on the range of the mention to be added.
    /// - Parameters:
    ///   - text: the text that was changed
    ///   - range: the range where text was changed
    /// - Returns: A new mention array
    func adjust(with text: String, on mentions: [SBUMention]? = nil, at range: NSRange) -> [SBUMention] {
        // ==== INFO ====
        // Based on the range of a new mention,
        // Coordinates the the ranges of current mentions
        
        // INFO: The expected length of the mentioned text except for the typing character
        let remainingLengthOfMention = text.utf16.count - range.length
        
        // ==== INFO ====
        // If there's an updates, uses `mentions`.
        // If there's no updates, uses current mentionedList
        let mentionedList = mentions ?? self.mentionedList
        
        return mentionedList.map { mention in
            guard mention.range.location >= NSMaxRange(range) else { return mention }
            let adjustedMention = mention
            adjustedMention.range.location += remainingLengthOfMention
            
            return adjustedMention
        }
    }
    
    /// Removes mention from the mentions array
    /// - Parameters:
    ///   - mention: The mention to remove
    /// - Returns: A new mention array
    func remove(_ mention: SBUMention) -> [SBUMention] {
        return mentionedList.filter { $0 != mention }
    }
    
    /// Returns the mentions being edited (if a mention is being edited)
    /// - Parameters:
    ///   - range: selectedRange
    /// - Returns: The mention being edited (if one exists)
    func mentionBeingEdited(at range: NSRange) -> [SBUMention]? {
        return mentionedList.filter {
            NSIntersectionRange(range, $0.range).length > 0 ||
            NSMaxRange(range) > $0.range.location &&
            NSMaxRange(range) < NSMaxRange($0.range)
        }
    }
}

// MARK: - NSAttributedString
extension SBUMentionManager {
    /// Adds a mentions into the text view
    /// - Parameters:
    ///   - user: The user to add
    ///   - attributedText: The attributed string of the text view.
    ///   - range: the range of the text that needs to be changed
    /// - Returns: `(NSAttributedString, NSRange)`: The updated string and the new selected range. `location` of a new `range` is right after the mentions
    func add(user: SBUUser,
             on attributedText: NSAttributedString,
             at range: NSRange) -> (NSAttributedString, NSRange) {
        let mentionedNickname = user.mentionedNickname()
        
        // INFO: Creates updated attributedText and range.
        let delemiter = SBUGlobals.userMentionConfig?.delimiter ?? " "
        let textToReplace = mentionedNickname + delemiter
        let replacedAttributes = replace(
            with: textToReplace,
            on: attributedText,
            at: range
        )
        let replacedAttributedText = replacedAttributes.0
        
        // INFO: The range in which `mentionTextAttribute` will be applied to.
        let adjustedRange = NSRange(location: range.location, length: mentionedNickname.utf16.count)
        
        // INFO: Applies the attributes to a range of the attributedText.
        let (appliedAttributedText, appliedRange) = apply(
            textAttributes: mentionTextAttributes,
            on: replacedAttributedText,
            at: adjustedRange
        )

        // INFO: The updated attributed text. The starting point of the text will be updated to `range.location + 1`
        let resultRange = NSRange(location: appliedRange.location + 1, length: appliedRange.length)
        return (appliedAttributedText, resultRange)
    }

    /// Updates the text view by making adjustments to the characters within a given range
    /// - Parameters:
    ///   - mentionText: The text to replace the characters with
    ///   - attributedText: The attributed string
    ///   - range: The range of characters to replace
    /// - Returns: `(NSAttributedString, NSRange)`: The updated string and the new selected range
    func replace(with text: String,
                 on attributedText: NSAttributedString,
                 at range: NSRange) -> (NSAttributedString, NSRange) {
        // ==== INFO ====
        // Changes text, changes string in `range` into mentionedText,
        // creates attributedText and updates range.
        // location info is important. (length is not important)
        
        let attributedText = NSMutableAttributedString(attributedString: attributedText)
        attributedText.mutableString.replaceCharacters(in: range, with: text)
        let replacedRange = NSRange(location: range.location + text.utf16.count, length: 0)

        return (attributedText, replacedRange)
    }
    
    /// Applies attributes to a given string and range
    /// - Parameters:
    ///   - attributes: the attributes to apply
    ///   - attributedString: The Attributed string
    ///   - range: the range to apply the attributes to
    /// - Returns: `(NSAttributedString, NSRange)`: The updated string and the new selected range
    func apply(textAttributes: [NSAttributedString.Key: Any],
               on attributedText: NSAttributedString,
               at range: NSRange) -> (NSAttributedString, NSRange) {
        // ==== INFO ====
        // Applies attributedText
        // Applies attributes from range to the attributed text.
        // set up range to be start from the character right after the end of applied text
        
        guard range.location != NSNotFound else {
            SBULog.error("Mention must have a range to insert into")
            return (NSMutableAttributedString(), NSRange())
        }
        
        guard NSMaxRange(range) <= attributedText.string.utf16.count else {
            SBULog.error("Mention range is out of bounds for the text length")
            return (NSMutableAttributedString(), NSRange())
        }

        let attributedText = NSMutableAttributedString(attributedString: attributedText)
        attributedText.addAttributes(textAttributes, range: range)

        return (attributedText, NSRange(location: NSMaxRange(range), length: 0))
    }
}

// MARK: - String
extension SBUMentionManager {
    /// Searches the mentionable range from the `text` with `options`.
    func searchMentionableRange(with text: String,
                                options: NSString.CompareOptions) -> NSRange {
        
        var foundRange = NSRange(location: NSNotFound, length: 0)
        
        let baseString = (text as NSString)
        
        // INFO: Does the text start with "@" or contain "@" ?
        let triggerRange = baseString.range(of: self.trigger, options: options)
        if triggerRange.location != NSNotFound {
            let delimiter = SBUGlobals.userMentionConfig?.delimiter ?? " "
            
            // Supports nickname start with trigger keywrod. (@@ case)
            var nicknameStartWithTrigger = false
            if triggerRange.location >= 1 {
                let nsString = text as NSString
                let prevtext = nsString.substring(with: NSRange(location: triggerRange.location-1, length: 1))
                if prevtext == trigger {
                    nicknameStartWithTrigger = true
                }
                
            }
            
            let spaceRange = baseString.range(
                of: delimiter,
                options: options,
                range: NSRange(location: 0, length: triggerRange.location)
            )
            
            let newLineRange = baseString.range(
                of: "\n",
                options: options,
                range: NSRange(location: 0, length: triggerRange.location)
            )
            
            let triggerLocation = triggerRange.location - (nicknameStartWithTrigger ? 1 : 0)
            
            /// The valid location of last delimiter
            let delimitedLocation: Int
            if spaceRange.location == NSNotFound {
                delimitedLocation = newLineRange.location
            } else if newLineRange.location == NSNotFound {
                delimitedLocation = spaceRange.location
            } else {
                delimitedLocation = max(spaceRange.location, newLineRange.location)
            }
            
            if  (delimitedLocation != NSNotFound && delimitedLocation + 1 == triggerLocation)
                    || triggerRange.location == 0
                    || nicknameStartWithTrigger && triggerRange.location == 1 {
                foundRange = baseString.range(of: self.trigger, options: options)
                if nicknameStartWithTrigger {
                    foundRange.location -= 1
                }
            }
        }
        
        return foundRange
    }

    /// Whether the location of the text enables mention or not.
    func isMentionEnabledAt(with text: String, location: Int) -> Bool {
        guard location != 0 else { return true }

        let start = text.utf16.index(text.startIndex, offsetBy: location - 1)
        let end = text.utf16.index(start, offsetBy: 1)
        let textBeforeTrigger = String(text.utf16[start ..< end]) ?? ""

        return (textBeforeTrigger == " " || textBeforeTrigger == "\n")
    }
}
