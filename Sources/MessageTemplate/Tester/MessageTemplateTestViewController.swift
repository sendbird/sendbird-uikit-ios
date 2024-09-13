//
//  MessageTemplateTestViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/10/14.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

public class MessageTemplateTestViewController: SBUBaseViewController {
    let scrollView = UIScrollView()
    var renderedView: UIView?
    
    var useParserTest: Bool = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = SBUBarButtonItem.backButton(
            target: self,
            selector: #selector(onTapLeftBarButton)
        )
        self.navigationItem.leftBarButtonItem = backButton

        if self.useParserTest == true {
            MessageTemplateParser().parserTest()
        }
    }
    
    @objc
    open func onTapLeftBarButton() {
        self.dismiss(animated: true)
//        self.navigationController?.popViewController(animated: true)
    }

    public override func setupViews() {
        super.setupViews()
        
        let mockJson = MessageTemplateParser.MockJson
        self.renderedView = SBUMessageTemplate.Renderer(
            with: mockJson,
            messageId: 1,
            actionHandler: { action in
                SBULog.info(action.data)
            }
        ) ?? SBUMessageTemplate.Renderer(
            body: .parsingError(text: "(Message template error)\nCan’t read this message.")
        )
        
        if let renderedView = self.renderedView {
            self.scrollView.addSubview(renderedView)
        }
        
        self.scrollView.clipsToBounds = true

        self.view.backgroundColor = .gray
        self.view.addSubview(self.scrollView)
    }
    
    public override func setupStyles() {
        super.setupStyles()
        
        self.scrollView.backgroundColor = .white
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        
        // Must implement belows
        
        self.scrollView.sbu_constraint(
            equalTo: self.view,
            leading: 0,
            trailing: 0,
            top: 0,
            bottom: 0
        )
        
        if let renderedView = self.renderedView {
            renderedView.sbu_constraint(equalTo: self.scrollView, leading: 0, trailing: 0, top: 0, bottom: 0)
            renderedView.sbu_constraint(widthAnchor: self.scrollView.widthAnchor, width: 0)
//            renderedView.sbu_constraint_greater(bottomAnchor: self.baseView.bottomAnchor, bottom: 0)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
