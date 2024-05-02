//
//  MessageTemplateParserTest.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/10/14.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

public class MessageTemplateParser: NSObject {
    static let MockJson = """
        {
            "version": "1",
            "body": {
              "items": [
                {
                  "type": "box",
                  "layout": "column",
                  "items": [
                    {
                      "type": "box",
                      "layout": "column",
                      "items": [
                        {
                          "type": "image",
                          "imageUrl": "https://dxstmhyqfqr1o.cloudfront.net/notifications/preset-notification-channel-cover.png",
                          "imageStyle": {
                            "contentMode": "aspectFill"
                          },
                          "viewStyle": {},
                          "metaData": {
                            "pixelWidth": "168",
                            "pixelHeight": "168"
                          }
                        },
                        {
                          "type": "box",
                          "layout": "column",
                          "viewStyle": {
                            "radius": "8",
                            "padding": {
                              "top": "12",
                              "bottom": "12",
                              "left": "12",
                              "right": "12"
                            }
                          },
                          "items": [
                            {
                              "type": "text",
                              "align": {
                                "horizontal": "left",
                                "vertical": "top"
                              },
                              "viewStyle": {},
                              "width": {
                                "type": "flex",
                                "value": "1"
                              },
                              "height": {
                                "type": "flex",
                                "value": "1"
                              },
                              "text": "Hello tez",
                              "textStyle": {
                                "color": "#ffbdb8bd",
                                "size": "16",
                                "weight": "normal"
                              },
                              "maxTextLines": "1"
                            },
                            {
                              "type": "text",
                              "align": {
                                "horizontal": "left",
                                "vertical": "top"
                              },
                              "viewStyle": {},
                              "width": {
                                "type": "fixed",
                                "value": "1"
                              },
                              "height": {
                                "type": "flex",
                                "value": "1"
                              },
                              "text": "Your order #123123 has been shipped.",
                              "textStyle": {
                                "color": "#ffbdb8bd",
                                "size": "16",
                                "weight": "normal"
                              },
                              "maxTextLines": "1"
                            },
                            {
                              "type": "textButton",
                              "viewStyle": {
                                "backgroundColor": "#E0E0E0",
                                "padding": {
                                  "top": "10",
                                  "bottom": "10",
                                  "left": "20",
                                  "right": "20"
                                }
                              },
                              "width": {
                                "type": "flex",
                                "value": "0"
                              },
                              "height": {
                                "type": "flex",
                                "value": "0"
                              },
                              "text": "Check status",
                              "textStyle": {
                                "color": "#742DDD",
                                "size": "16",
                                "weight": "normal"
                              },
                              "maxTextLines": "5",
                              "action": {
                                "type": "web",
                                "data": "https://naver.com"
                              }
                            }
                          ],
                          "height": {
                            "type": "fixed",
                            "value": "300"
                          },
                          "width": {
                            "type": "flex",
                            "value": "0"
                          },
                          "align": {
                            "horizontal": "left",
                            "vertical": "top"
                          }
                        }
                      ],
                      "viewStyle": {}
                    }
                  ],
                  "viewStyle": {}
                }
              ]
            }
          }
        """
    
    public static func getMock(widthT: String, widthV: Int, heightT: String, heightV: Int, contentMode: String) -> String {
        return """
    {"version": 1,"body": {"items": [{"type": "box","layout": "column","items": [{"type": "image","metaData": {"pixelWidth": 4000,"pixelHeight": 3000},"width": {"type": "\(widthT)","value": \(widthV)},"height": {"type": "\(heightT)","value": \(heightV)},"imageStyle": {"contentMode": "\(contentMode)"},"imageUrl": "https://images.unsplash.com/photo-1579393329936-4bc9bc673651?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format"},{"type": "box","viewStyle": {"padding": {"top": 12,"right": 12,"bottom": 12,"left": 12}},"layout": "column","items": [{"type": "box","layout": "row","items": [{"type": "box","layout": "column","items": [{"type": "text","text": "Notification channel creation guide","maxTextLines": 3,"viewStyle": {"padding": {"top": 0,"bottom": 6,"left": 0,"right": 0}},"textStyle": {"size": 16,"weight": "bold"}},{"type": "text","text": "Notification Center is basically a group channel to which a single user, the receiver of a notification, belongs. A notification channel, which is a single group channel dedicated to the Notification Center, must be created for each user.","maxTextLines": 10,"textStyle": {"size": 14}}]}]},{"type": "box","layout": "column","items": [{"type": "box","viewStyle": {"margin": {"top": 16,"bottom": 0,"left": 0,"right": 0}},"align": {"horizontal": "left","vertical": "center"},"layout": "row","action": {"type": "web","data": "www.sendbird.com"},"items": [{"type": "box","viewStyle": {"margin": {"top": 0,"bottom": 0,"left": 12,"right": 0}},"layout": "column","items": [{"type": "text","text": "Title","maxTextLines": 1,"textStyle": {"size": 16,"weight": "bold"}},{"type": "text","viewStyle": {"margin": {"top": 4,"bottom": 0,"left": 0,"right": 0}},"text": "Hi","maxTextLines": 1,"textStyle": {"size": 14}}]}]}]}]}]}]}}
    """
    }
    /**
     var tmpData = MessageTemplateParser.getMock(
     //            widthT: "fixed", widthV: 200,
     //            widthT: "flex", widthV: 0,
     widthT: "flex", widthV: 1,
     //            heightT: "fixed", heightV: 200,
     //            heightT: "flex", heightV: 0,
     heightT: "flex", heightV: 1,
     //            contentMode: "aspectFit"
     //            contentMode: "aspectFill"
     contentMode: "scalesToFill"
     )
     */
    
    public func parserTest() {
        let data = Data(MessageTemplateParser.MockJson.utf8)
        let decoded = try? JSONDecoder().decode(SBUMessageTemplate.Syntax.TemplateView.self, from: data)
        
        let items = decoded?.body?.items
        
        let item = items?[safe: 0]
        switch item {
        case .box(let box):
            print(box)
        case .text(let text):
            print(text)
        case .image(let image):
            print(image)
        case .textButton(let textButton):
            print(textButton)
        case .imageButton(let imageButton):
            print(imageButton)
        case .carouselView(let carouselItem):
            print(carouselItem)
        case .none:
            break
        }
    }
}
