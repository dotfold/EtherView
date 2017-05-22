//
//  CardView.swift
//  EtherView
//
//  Created by James McNamee on 22/5/17.
//  Copyright © 2017 James McNamee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON

@IBDesignable class CardView : UIView {
    let disposeBag = DisposeBag()
    var exchangeVM: ExchangeViewModel! = nil {
        didSet {
            initBindings()
        }
    }
    
    @IBOutlet weak var exchangeName: UILabel!
    @IBOutlet weak var tradePrice: UILabel!
    @IBOutlet weak var tradeTx: UILabel!
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        self.initCommon()
    }
    
    required init? (coder: NSCoder) {
        super.init(coder: coder)
        self.initCommon()
    }
    
    fileprivate func initCommon () {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0).cgColor
    }
    
    // set up bindings from the viewmodel when the viewmodel is set on this class
    func initBindings () {
        
        exchangeVM.exchangeTradeLastPrice$
            // a UI side effect
            // flash the tile background to indicate new data has arrived
            .do(onNext: { [unowned self] _ in
                let v = UIView(frame: self.bounds)
                v.backgroundColor = UIColor(red: 62/255, green: 100/255, blue: 163/255, alpha: 1.0)
                v.alpha = 0.25
                
                self.addSubview(v)
                UIView.animate(withDuration: 0.25, animations: {
                    v.alpha = 0.0
                }, completion: {(finished:Bool) in
                    v.removeFromSuperview()
                })
            })
            .bind(to: tradePrice.rx.text)
            .addDisposableTo(disposeBag)
        
        // transactions per miniute display (sliding window)
        exchangeVM.exchangeTx$
            .map({ tx in
                return "\(tx) tx/min"
            })
            .bind(to: tradeTx.rx.text)
            .addDisposableTo(disposeBag)
        
        // name of the exchange set on the viewmodel
        exchangeVM.exchangeName$
            .bind(to: exchangeName.rx.text)
            .addDisposableTo(disposeBag)
    }
}
