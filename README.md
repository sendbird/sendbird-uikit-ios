
# [Sendbird](https://sendbird.com) Sendbird X ChatGPT E-Commerce AI Chatbot Demo

[![Platform](https://img.shields.io/badge/platform-iOS-orange.svg)](https://cocoapods.org/pods/SendBirdUIKit)
[![Languages](https://img.shields.io/badge/language-Swift-orange.svg)](https://github.com/sendbird/sendbird-uikit-ios)
[![Commercial License](https://img.shields.io/badge/license-Commercial-green.svg)](https://github.com/sendbird/sendbird-uikit-ios/blob/main/LICENSE.md)

This demo app showcases what AI Chatbots with Sendbird can do to enhance the customer experience of your service with more personalized and comprehensive customer support.
Utilizing OpenAI’s GPT3.5 and its Function Calling functionality, ***Sendbird helps you build a chatbot that can go extra miles: providing informative responses with the data source you feed to the bot, accommodating customer’s requests such as tracking and canceling their orders, and even recommending new products.*** Create your own next generation AI Chatbot by following the tutorial below.

## How to open the demo app
1. Open Xcode Demo project
```shell
open Sample/QuickStart.xcodeproj
```
2. Change the `appId` in `AppDelegate.swift` to your Sendbird application ID.
```swift
SendbirdUI.initialize(applicationId: <#applicationID: String#>)
```

## Table of Contents
1. [Use case: E-commerce](##use-case-e-commerce)
2. [How it works](##how-it-works)
3. [Demo app settings](##demo-app-settings)
4. [System Message and Function Calling](##system-message-and-function-calling)
5. [Welcome Message and Quick Replies](##welcome-message-and-quick-replies)
6. [UI Components](##ui-components)
7. [Limitations](##limitations)

## Use case: E-commerce
This demo app demonstrates the implementation of the AI Chatbot tailored for e-commerce. It includes functionalities such as ***retrieving the order list, showing order details, canceling orders, and providing recommendations.*** By leveraging ChatGPT’s new feature [Function Calling](https://openai.com/blog/function-calling-and-other-api-updates), the Chatbot now can make an API request to the 3rd party with a predefined Function Calling based on customer’s enquiry. Then it parses and presents the response in a conversational manner, enhancing overall customer experience.

## How it works
<img width="2556" alt="image" src="https://github.com/sendbird/sendbird-uikit-ios/assets/104121286/12a8cb5f-8127-41cb-9570-3c979f977ad4">

1. A customer sends a message containing a specific request on the client app to the Sendbird server.
2. The Sendbird server then delivers the message to Chat GPT.
3. Chat GPT then analyzes the message and determines that it needs to make a Function Calling request. In response, it delivers the relevant information to the Sendbird server.
4. The Sendbird server then sends back a Function Calling request to Chat GPT. The request contains both Function Calling data Chat GPT previously sent and the 3rd party API information provided by the client app. This configuration must be set on the client-side.
5. The 3rd party API returns a response in `data` to the Sendbird server.
6. The Sendbird server passes the `data` to Chat GPT.
7. Once received, Chat GPT analyzes the data and returns proper responses to the Sendbird server as `data`.
8. The Sendbird server passes Chat GPT’s answer to the client app.
9. The client app can process and display the answer with Sendbird Chat UIKit.

***Note***: Currently, calling a 3rd party function is an experimental feature, and some logics are handled on the client-side for convenience purposes. Due to this, the current version for iOS (3.7.0 beta) will see breaking changes in the future, especially for QuickReplyView and CardView. Also, the ad-hoc support from the server that goes into the demo may be discontinued at any time and will be replaced with a proper feature on Sendbird Dashboard in the future.

## Demo app settings
To run the demo app, you must specify `system_message` and `functions` in `ai_attrs`. Each provides the AI Chatbot with directions on how to interpret a customer’s message and respond to it using the predefined functions.

In addition, you can enhance user experience by streamlining the communication with a Welcome Message and Quick Replies. Using Quick Replies can improve the clarity of your customer’s intention as they are presented with a list of predefined options determined by you.

## System Message and Function Calling
The following is a prompt sample of `system_message` and `functions` in `json` format, which are contained in `ai_attrs`. The `system_message` value serves as guidelines on how the bot should handle customer inquiries while `functions` lists the function calls that Chat GPT can make when it determines that a specific request was submitted. The keys and values in the prompt will be stored in the `messageParams.data` property in `string`.

`ai_attrs`
 - `system_message`: this declares the persona and responsibilities of your Chatbot. You can also specify response examples, limitations, and the customer’s nickname and ID.
 - `functions`: this contains information related to Function Calling, which are a list of functions that Chat GPT can call and the 3rd party API information to send the Function Calling request to.
   - `request`: 3rd party API information
      - `headers`: header for the api request
     - `method`: a method for the API request, such as `GET`, `POST`, `PUT`, or `DELETE`
     - `url`: the API request URL
   - `name`: the name of the Function Calling request
   - `description`: the description about the Function Calling request. It can detail when to call the function and what action to be taken. Chat GPT will use this information to analyze the customer’s message and determine whether to call the function or not.
   - `parameter`: This contains a list of arguments required for the Function Calling.

SBUBaseChannelViewManger.swift
```swift
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
```

## Welcome Message and Quick Replies
<img width="386" alt="image" src="https://github.com/sendbird/sendbird-uikit-ios/assets/104121286/b29f481f-8274-4a63-a4ca-a27bc642423d">


The following is a prompt sample of `first_message_data` in `json` format. The object contains two pieces of information: `message` and `data`. The string value in message will act as a Welcome Message while values in `data` represent the Quick Replies that the customer can choose from. The keys and values in the prompt will be stored in the `channelCreateParams.data` property in `string`.

`first_message_data`
 - `data`: you can use Quick Replies as a preset of messages that a customer can choose from. These Quick Replies will be displayed with its own UI components. Use `option` for Quick Replies in the `data` object
   - `options`: this contains a list of Quick Reply messages. A customer can choose a predefined item from the list, which enhances the clarity of the customer’s request and thus helps the AI Chatbot understand their intention.
 - `message`: this is a Welcome Message to greet a customer when they open a channel and initiate conversation with an AI ChatBot. 

SBUCreateChannelViewModel.swift
```swift
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
```

## UI Components
### CardView
The `data` in the response are displayed in a Card view. In the demo, information such as order items and their delivery status can be displayed in a card with an image, title, and description. Customization of the view can be done through `cardViewParamsCollectionBuilder` and `SBUCardViewParams`. The following codes show how to set the Card view of order status.

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

### QuickReplyView
The following codes demonstrate how to set the view for Quick Replies. The values in `options` of `first_message_data.data` are used as Quick Replies.

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

## Limitations
`Tokens`
The maximum number of tokens allowed for `data` is 4027. Make sure that the settings information including the system message does not exceed the limit.
