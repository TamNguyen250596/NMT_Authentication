//
//  AuthenticationMethodsView.swift
//  NMT-Authentication
//
//  Created by Nguyen Minh Tam on 05/04/2022.
//

import UIKit

class AuthenticationMethodsView: UIView {
    //MARK: Properties
    private let faceIDButton: UIButton = {
        let button = UIButton()
        button.setTitle("FaceID", for: .normal)
        return button
    }()
    
    //MARK: View cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Helpers
    private func setupUI() {
        
    }

}
