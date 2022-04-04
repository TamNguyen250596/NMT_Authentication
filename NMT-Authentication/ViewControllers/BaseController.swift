//
//  BaseController.swift
//  NMT-Authentication
//
//  Created by Nguyen Minh Tam on 31/03/2022.
//

import UIKit
import SnapKit
import Localize_Swift

class BaseController: UIViewController {
    //MARK: Properties

    
    //MARK: View cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    

    //MARK: Helpers
    func setupUI() {
        
        view.backgroundColor = .white
        
    }

}
