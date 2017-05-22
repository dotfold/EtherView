//
//  ExchangeDetailViewController.swift
//  EtherView
//
//  Created by James McNamee on 18/5/17.
//  Copyright © 2017 James McNamee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ExchangeDetailViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var exchangeVM: ExchangeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exchangeVM.exchangeName$
            .bind(to: nameLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        // bind exchange image to custom navigation bar uiimage
    }
}
