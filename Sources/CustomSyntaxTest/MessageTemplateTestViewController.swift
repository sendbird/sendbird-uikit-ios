//
//  MessageTemplateTestViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/10/14.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

public class MessageTemplateTestViewController: SBUBaseViewController {

    let baseView = UIView()
    var renderedView: UIView?
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = SBUBarButtonItem.backButton(
            vc: self,
            selector: #selector(onTapLeftBarButton)
        )
        self.navigationItem.leftBarButtonItem = backButton

    }
    
    @objc open func onTapLeftBarButton() {
        self.dismiss(animated: true)
//        self.navigationController?.popViewController(animated: true)
    }

    public override func setupViews() {
        super.setupViews()

        let mockJson = MessageTemplateParser.MockJson
        self.renderedView = MessageTemplateRenderer(
            with: mockJson,
            actionHandler: { action in
                SBULog.info(action.data)
            }
        ) ?? MessageTemplateRenderer(
            body: .parsingError(text: "(Message template error)\nCan’t read this message.")
        )
        
        if let renderedView = self.renderedView {
            self.baseView.addSubview(renderedView)
        }
        
        self.baseView.roundCorners(corners: .allCorners, radius: 16.0)
        self.baseView.clipsToBounds = true

        self.view.backgroundColor = .gray
        self.view.addSubview(self.baseView)
    }
    
    public override func setupStyles() {
        super.setupStyles()
        
        self.baseView.backgroundColor = .white
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        
        // Must implement belows
        
        self.baseView.sbu_constraint_equalTo(
            leadingAnchor: self.view.safeAreaLayoutGuide.leadingAnchor, leading: 20,
            trailingAnchor: self.view.safeAreaLayoutGuide.trailingAnchor, trailing: -20
        )
        
        self.baseView.sbu_constraint(equalTo: self.view, centerX: 0, centerY: 0)
        
        if let renderedView = self.renderedView {
            renderedView.sbu_constraint(equalTo: self.baseView, leading: 0, trailing: 0, top: 0, bottom: 0)
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
