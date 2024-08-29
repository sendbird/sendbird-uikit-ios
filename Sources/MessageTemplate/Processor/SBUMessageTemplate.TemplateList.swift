//
//  SBUMessageTemplate.TemplateList.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/02/19.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// MARK: - TemplateList object
extension SBUMessageTemplate {
    struct TemplateList {
        var templates: [SBUMessageTemplate.TemplateModel] = []
        
        enum CodingKeys: String, CodingKey {
            case templates
        }
        
        init(with jsonData: Data) {
            do {
                guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else { return }
                guard let templateList = json[CodingKeys.templates.rawValue] as? [[String: Any]] else { return }
                
                self.templates = try templateList.compactMap { templateDic in
                    try TemplateModel.createTemplate(with: templateDic)
                }
            } catch {
                SBULog.error(error.localizedDescription)
            }
        }
    }
}

extension SBUMessageTemplate {
    struct TemplateModel: Codable {
        let key: String // unique
        let name: String
        let uiTemplate: String // JSON_OBJECT
        let dataTemplate: String // JSON_OBJECT
        let colorVariables: String // JSON_OBJECT
        let createdAt: Int64
        let updatedAt: Int64
        
        enum CodingKeys: String, CodingKey {
            case key
            case name
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case uiTemplate = "ui_template"
            case dataTemplate = "data_template"
            case colorVariables = "color_variables"
        }
        
        var uiTemplateRemovedEscape: String {
            self.uiTemplate.removedNewLineEscape
        }
        
        var colorDictionary: [String: String] {
            do {
                let data = Data(self.colorVariables.utf8)
                guard let variables = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return [:] }
                return variables.reduce(into: [String: String]()) { $0[$1.key] = "\($1.value)" }
            } catch {
                SBULog.error(error.localizedDescription)
                return [:]
            }
        }
    }
}
    
extension SBUMessageTemplate {
    struct RawValues {
        let values: [String: Any]
        
        func value(from key: SBUMessageTemplate.TemplateModel.CodingKeys) -> Any? {
            values[key.rawValue]
        }
    }
}

extension SBUMessageTemplate.TemplateModel {
    // original
    static func createTemplate(with data: [String: Any]) throws -> SBUMessageTemplate.TemplateModel? {
        let template = SBUMessageTemplate.RawValues(values: data)
        if let key = template.value(from: .key) as? String,
           let name = template.value(from: .name) as? String,
           let createdAt = template.value(from: .createdAt) as? Int64,
           let updatedAt = template.value(from: .updatedAt) as? Int64 {

            let uiTemplate = template.value(from: .uiTemplate) as? [String: Any] ?? [:]
            let dataTemplate = template.value(from: .dataTemplate) as? [String: Any] ?? [:]
            let colorVariables = template.value(from: .colorVariables) as? [String: Any] ?? [:]
            
            let uiTemplateJson = try JSONSerialization.data(withJSONObject: uiTemplate, options: [])
            let uiTemplateJsonStr = String(data: uiTemplateJson, encoding: .utf8)
            
            let dataTemplateJson = try JSONSerialization.data(withJSONObject: dataTemplate, options: [])
            let dataTemplateJsonStr = String(data: dataTemplateJson, encoding: .utf8)

            let colorVariablesJson = try JSONSerialization.data(withJSONObject: colorVariables, options: [])
            let colorVariablesJsonStr = String(data: colorVariablesJson, encoding: .utf8)
            
            let template = SBUMessageTemplate.TemplateModel(
                key: key,
                name: name,
                uiTemplate: uiTemplateJsonStr ?? "",
                dataTemplate: dataTemplateJsonStr ?? "",
                colorVariables: colorVariablesJsonStr ?? "",
                createdAt: createdAt,
                updatedAt: updatedAt
            )
            
            return template
        }
        return nil
    }
    
}
