
# [Sendbird](https://sendbird.com) Sendbird X ChatGPT E-Commerce AI Chatbot Demo

[![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)](https://cocoapods.org/pods/SendBirdUIKit)
[![Languages](https://img.shields.io/badge/language-Swift-orange.svg)](https://github.com/sendbird/sendbird-uikit-ios)
[![Commercial License](https://img.shields.io/badge/license-Commercial-green.svg)](https://github.com/sendbird/sendbird-uikit-ios/blob/main/LICENSE.md)

*Read this in other languages: [Korean](README.ko.md)*

This is a demo app for Sendbird X ChatGPT E-Commerce AI ChatBot. It is built with [Sendbird UIKit iOS](https://github.com/sendbird/sendbird-uikit-ios)

## Table of Contents
1. [Introduction](##introduction)
2. [Customization](##customization)

## Introduction
In this sample, an E-Commerce AI Chatbot integrated with Sendbird Chat and GPT Function Calling functionality has been implemented. 
Through the ChatGPT Function Calling feature, you can expand the capabilities of the ChatBot by calling 3rd Party APIs that the existing ChatBot could not provide.

### system_message
In ChatGPT, you can define the role that the ChatBot should perform through system_message.
The following system_message has been defined to implement the E-commerce scenario.
```
"system_message": "You are an AI assistant that handles and manages customer orders. You will be interacting with customers who have the orders..."
```
For more information, refer to [System message: how to force ChatGPT API to follow it](https://community.openai.com/t/system-message-how-to-force-chatgpt-api-to-follow-it/82775).

### function_calling
In ChatGPT, you can interact with external functions during a conversation with ChatGPT through function_calling.
In function_calling, the GPT recognizes the content of the function defined in the description in advance,
During the conversation with the user, it requests to call the function defined in function_calling.
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
For more information, refer to [Function Calling](https://openai.com/blog/function-calling-and-other-api-updates).

## Customization
### Application ID setting
Set the Application ID created through the Sendbird Dashboard as follows through `SendbirdUI.initialize`.

AppDelegate.swift
```swift
SendbirdUI.initialize(applicationId: "{Application ID}") 
```

### Sendbird X GPT system_message and function_calling setting
Currently, it is an experimental feature. To use Sendbird X GPT system_message and function_calling, you need to override the `createChannel` function of `SBUCreateChannelViewModel`, and define `data`.

`data` must be defined in JSON format, and `system_message` and `functions` must be defined. `system_message` defines the role to be performed by ChatGPT. To ensure that GPT generates recommended Quick Replies for each conversation, add the following content to `system_message`: 

`Ensure a maximum of three highly relevant recommended quick replies are always included in the response with this format JSON^{"options": ["I want to check the order list", "I'd like to cancel my order", "Please recommend me items", "Yes I want cancel it", "No I don't want",  "I don’t like any of them, thank you"]}^NSOJ`

If there is a sentence in the response content of ChatGPT with the following format `JSON^{"option":["", "", "", "", "", ""]}^NSOJ`, the Sendbird Server parses the content and delivers the `option` content as `quick_reply`.

`functions` define the ability for ChatGPT to call external functions through function_calling. `functions` define `request`, `name`, `description`, `parameters`. `request` defines the information of the API to be called when calling an external function through function_calling. When GPT requests Function calling, the Sendbird Server checks the corresponding function and calls the API defined in `request` to generate `function_response`.

`name`, `description`, `parameters` are the contents needed when GPT requests function_calling. For more details, please refer to [Function Calling](https://openai.com/blog/function-calling-and-other-api-updates).

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
}
```

### Welcome Message Setting
You can send a Welcome Message when the user first starts a conversation with the Bot.
To send a Welcome Message, define `first_message_data` by overriding the `createChannel` function of `SBUCreateChannelViewModel` as follows.

The first `message` of `first_message_data` defines the Welcome Message, and data defines Quick Reply.

SBUCreateChannelViewModel.swift
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
}
```

### CardView Customization
During a conversation with ChatGPT, you can receive the response from a 3rd party API call via `function_response`. Based on this data, a CardView can be dynamically created. To create a CardView, define `SBUGlobalCustomParams.cardViewParamsCollectionBuilder` and define a closure that returns `SBUCardViewParams`.

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
Quick Reply is created based on the `options` defined in the `system_message` during a conversation with ChatGPT. To use Quick Reply, you need to add the following content. (Note: The specific content needed to be added is not provided in the original text)

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