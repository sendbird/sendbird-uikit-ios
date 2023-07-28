# [Sendbird](https://sendbird.com) Sendbird X ChatGPT E-Commerce AI Chatbot Demo

[![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)](https://cocoapods.org/pods/SendBirdUIKit)
[![Languages](https://img.shields.io/badge/language-Swift-orange.svg)](https://github.com/sendbird/sendbird-uikit-ios)
[![Commercial License](https://img.shields.io/badge/license-Commercial-green.svg)](https://github.com/sendbird/sendbird-uikit-ios/blob/main/LICENSE.md)

This is a demo app for Sendbird X ChatGPT E-Commerce AI ChatBot. It is built with [Sendbird UIKit iOS](https://github.com/sendbird/sendbird-uikit-ios)

## Table of Contents
1. [Introduction](##introduction)
2. [Customization](##customization)

## Introduction
이 샘플에서는 Sendbird Chat과 GPT Function Calling기능이 통합된 E-Commerce AI Chatbot을 구현하였습니다.
ChatGPT Function Calling기능을 통하여 기존의 ChatBot이 제공하지 못했던 3rd Party API를 호출하여 ChatBot의 기능을 확장할 수 있습니다.

### system_message
ChatGPT에서는 system_message를 통해서 ChatBot이 수행해야하는 역할을 정의할수 있습니다.
다음과 같이 system_message를 정의하여 E-commerce 시나리오를 구현하였습니다.
```
"system_mesasge": "You are an AI assistant that handles and manages customer orders. You will be interacting with customers who have the orders..."
```

자세한 내용은 [System message: how to force ChatGPT API to follow it](https://community.openai.com/t/system-message-how-to-force-chatgpt-api-to-follow-it/82775)를 참고 하세요. 

### function_calling
ChatGPT에서 function_calling을 통해서 ChatGPT대화 중 외부 기능과 연동을 할 수 있습니다.
function_calling에서 정의한 function의 description내용을 GPT가 사전에 인지하여,
사용자와의 대화 중 function_calling에 정의된 function 호출을 요청합니다.
```
"functions": [
  {
    "name": "get_order_list",
    "description": "Get the order list of the customer",
    "parameters": {
      "type": "object",
      "properties": {
        "customer_id": {
          "type": "string",
          "description": "Customer ID of the customer"
        }
      },
      "required": ["customer_id"]
    }
  }
]
```

자세한 내용은 [Function Calling](https://openai.com/blog/function-calling-and-other-api-updates)을 참고하세요.

## Customization
### Application ID setting

AppDelegate.swift
```swift
SendbirdUI.initialize(applicationId: "5367180A-FA3F-4262-876C-6607D93EDC74") 
```

### Sendbird X GPT system_message and function_calling setting
이번 Demo에서는 E-Commerce에 시나리오 중 Order list, Order Details, Order Cancel, Recommend Items

SBUBaseChannelViewManger.swift
```swift
open func sendUserMessage(text: String, parentMessage: BaseMessage? = nil) {
    let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
    let messageParams = UserMessageCreateParams(message: text)

    let data = """
        {
            "ai_attrs":{
                "system_message":"You are an AI assistant that handles and manages customer orders. You will be interacting with customers who have the orders. Ensure a maximum of three highly relevant recommended quick replies are always included in the response with this format JSON^{\\\"options\\\": [\\\"I want to check the order list\\\", \\\"I'd like to cancel my order\\\", \\\"Please recommend me items\\\", \\\"Yes I want cancel it\\\", \\\"No I don't want\\\",  \\\"I don’t like any of them, thank you\\\"]}^NSOJ\\\\n1. Available 24/7 to assist customers with their order inquiries.\\\\n2. Customers may request to check the status of their orders or cancel them.\\\\n3. You have access to the customer's order list and the order details associated with it.\\\\n4. When a customer requests to cancel an order, you need to confirm the specific order number from their order list before proceeding.\\\\n5. Ensure confirmation for the cancellation to the customer once it has been processed successfully.\\\\nIf a customer needs further assistance after order cancellation, be ready to provide it\\\\nYou will be interacting with customers named John and cumstomer id is 12345",
                "functions":[
                    {
                        "request":{
                            "headers":{},
                            "method":"GET",
                            "url":"https://aovxtjod0a.execute-api.ap-northeast-2.amazonaws.com/demo/get_order_list"
                        },
                        "name":"get_order_list",
                        "description":"Get the order list of the customer",
                        "parameters":{
                            "type":"object",
                            "properties":{
                                "customer_id":{
                                    "description":"Customer ID of the customer",
                                    "type":"string"
                                }
                            },
                            "required":["customer_id"]
                        }
                    },
                    {
                        "request":{
                            "headers":{},
                            "method":"GET",
                            "url":"https://aovxtjod0a.execute-api.ap-northeast-2.amazonaws.com/demo/get_order_details"
                        },
                        "name":"get_order_details",
                        "description":"Get the order details of the customer",
                        "parameters":{
                            "type":"object",
                            "properties":{
                                "order_id":{
                                    "description":"Order ID of the customer",
                                    "type":"string"
                                }
                            },
                            "required":["order_id"]
                        }
                    },
                    {
                        "request":{
                            "headers":{},
                            "method":"GET",
                            "url":"https://aovxtjod0a.execute-api.ap-northeast-2.amazonaws.com/demo/cancel_order"
                        },
                        "name":"cancel_order",
                        "description":"Cancel the order of the customer",
                        "parameters":{
                            "type":"object",
                            "properties":{
                                "order_id":{
                                    "description":"Order ID of the customer",
                                    "type":"string"
                                }
                            },
                            "required":["order_id"]
                        }
                    },
                    {
                        "request":{
                            "headers":{},
                            "method":"GET",
                            "url":"https://aovxtjod0a.execute-api.ap-northeast-2.amazonaws.com/demo/get_recommendation"
                        },
                        "name":"get_recommendation",
                        "description":"Get the recommendation list of the customer",
                        "parameters":{
                            "type":"object",
                            "properties":{
                                "customer_id":{
                                    "description":"Customer ID of the customer",
                                    "type":"string"
                                }
                            },
                            "required":["customer_id"]
                        }
                    }
                ]
            }
        }
    """

    do {
        if let dataObject = data.data(using: .utf8),
           let jsonObject = try JSONSerialization.jsonObject(with: dataObject, options: []) as? [String: Any] {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                messageParams.data = jsonString
            }
        }
    } catch {
        print("Error while converting to JSON: \(error)")
    }

    SBUGlobalCustomParams.userMessageParamsSendBuilder?(messageParams)
    
    if let parentMessage = parentMessage,
        SendbirdUI.config.groupChannel.channel.replyType != .none {
        messageParams.parentMessageId = parentMessage.messageId
        messageParams.isReplyToChannel = true
    }
    messageParams.mentionedMessageTemplate = ""
    messageParams.mentionedUserIds = []
    
    self.sendUserMessage(messageParams: messageParams, parentMessage: parentMessage)
}
```

### Welcome Message Setting

```swift
public func createChannel(params: GroupChannelCreateParams,
                              messageListParams: MessageListParams? = nil) {
        
    let data: [String: Any] = [
        "first_message_data": [
            [
                "data": [
                    "options": [
                        "I want to check the order list",
                        "I want to cancel my order",
                        "Please recommend me items"
                    ]
                ],
                "message": "Hello! I'm E-Commer's chatbot. I'm still learning but I'm here 24/7 to answer your question or connect you with the right person to help."
            ]
        ]
    ]
                    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            params.data = jsonString
        }
    } catch {
        print("Error while converting to JSON: \(error)")
    }
    
    SBULog.info("""
        [Request] Create channel with users,
        Users: \(Array(self.selectedUserList))
        """)
    self.delegate?.shouldUpdateLoadingState(true)
    
    GroupChannel.createChannel(params: params) { [weak self] channel, error in
        defer { self?.delegate?.shouldUpdateLoadingState(false) }
        guard let self = self else { return }
        
        if let error = error {
            SBULog.error("""
                [Failed] Create channel request:
                \(String(error.localizedDescription))
                """)
            self.delegate?.didReceiveError(error)
            return
        }
        
        SBULog.info("[Succeed] Create channel: \(channel?.description ?? "")")
        self.delegate?.createChannelViewModel(
            self,
            didCreateChannel: channel,
            withMessageListParams: messageListParams
        )
    }
}
```

### CardView Customization
SBUUserMessageCell.swift
```swift
// MARK: Card List
if let cardListView = self.cardListView {
    self.contentVStackView.removeArrangedSubview(cardListView)
}

// Parse JSON from received message data
let json = JSON(parseJSON: message.data)
let functionResponse = json["function_response"]

if functionResponse.type != .null {
    let statusCode = functionResponse["status_code"].intValue
    let endpoint = functionResponse["endpoint"].stringValue
    let response = functionResponse["response"]

    if statusCode == 200 {
        filterMessage(message, &customText)

        if endpoint.contains("get_order_list") {
            SBUGlobalCustomParams.cardViewParamsCollectionBuilder = { messageData in
                guard let json = try? JSON(parseJSON: messageData) else { return [] }

                return json.arrayValue.compactMap { order in
                    let deliveryStatus = order["status"].stringValue
                    var icon: String = ""

                    switch deliveryStatus {
                    case "delivered":
                        icon = "✅"
                    case "delivering":
                        icon = "🚚"
                    case "preparing":
                        icon = "⏳"
                    default:
                        break
                    }

                    let titleWithIcon = icon.isEmpty ? "Order #\(order["id"].stringValue)" : "\(icon) Order #\(order["id"].stringValue)"

                    return SBUCardViewParams(
                            imageURL: nil,
                            title: titleWithIcon,
                            subtitle: "Your Order \(deliveryStatus)",
                            description: "Items:" + ((order["items"].arrayObject as? [String])?.joined(separator: ", "))!,
                            link: nil
                    )
                }
            }
            if let items = try?SBUGlobalCustomParams.cardViewParamsCollectionBuilder?(response.rawString()!){
                self.addCardListView(with: items)
            }
        } else if endpoint.contains("get_order_details") {
            SBUGlobalCustomParams.cardViewParamsCollectionBuilder = { messageData in
                guard let json = try? JSON(parseJSON: messageData) else { return [] }

                // Convert the single order object into a SBUCardViewParams object
                let orderParams = SBUCardViewParams(
                        imageURL: nil,
                        title: "Order #\(json["id"].stringValue) by \(json["customer_name"].stringValue)",
                        subtitle: "- Status: \(json["status"].stringValue)\n- Estimated Delivery Date: \(json["estimatedDeliveryDate"].stringValue)",
                        description: "- Items: " + ((json["items"].arrayObject as? [String])?.joined(separator: ", "))! + "\n- Total Price: $\(json["purchasePrice"].intValue)",
                        link: nil
                )

                // Return the SBUCardViewParams object inside an array
                return [orderParams]
            }
            if let items = try?SBUGlobalCustomParams.cardViewParamsCollectionBuilder?(response.rawString()!){
                self.addCardListView(with: items)
            }
        } else if endpoint.contains("get_recommendation") {
            disableWebview = true
            SBUGlobalCustomParams.cardViewParamsCollectionBuilder = { messageData in
                guard let json = try? JSON(parseJSON: messageData) else { return [] }

                return json.arrayValue.compactMap { item in
                    return SBUCardViewParams(
                            imageURL: item["image"].stringValue,
                            title: item["name"].stringValue,
                            subtitle: "$\(item["price"].intValue)",
                            description: nil,
                            link: nil
                    )
                }
            }
            if let items = try?SBUGlobalCustomParams.cardViewParamsCollectionBuilder?(response.rawString()!){
                self.addCardListView(with: items)
            }
        }

    }
} else {
    self.cardListView = nil
}

```

### Quick Reply Setting
SBUUserMessageCell.swift
```swift
// MARK: Quick Reply        
if let quickReplyView = self.quickReplyView {
    quickReplyView.removeFromSuperview()
    self.quickReplyView = nil
}

if let replyOptions = message.quickReply?.options, !replyOptions.isEmpty {
    self.updateQuickReplyView(with: replyOptions)
}
```