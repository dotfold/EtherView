//
//  ExchangeDetailViewController.swift
//  EtherView
//
//  Created by James McNamee on 18/5/17.
//  Copyright © 2017 James McNamee. All rights reserved.
//

import UIKit

class ExchangeDetailViewController: UIViewController {
    
    var exchange: Exchange?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Exchange Detail"
        
        if let received = exchange {
            print(received)
        }
    }
}
