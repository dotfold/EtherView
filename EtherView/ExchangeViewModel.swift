//
//  CardViewModel.swift
//  EtherView
//
//  Created by James McNamee on 22/5/17.
//  Copyright © 2017 James McNamee. All rights reserved.
//

import RxSwift
import RxCocoa
import SwiftyJSON

class ExchangeViewModel {
    
    // trades
    var exchangeTrade = Variable<JSON>(JSON(0))
    var exchangeTrade$: Observable<JSON>!
    var exchangeTradeLastPrice$: Observable<String>!
    
    // transactions per minute (sliding window)
    var exchangeTx = Variable<Int>(0)
    var exchangeTx$: Observable<Int>!
    
    // exchange name
    var exchangeName = Variable<String>("")
    var exchangeName$: Observable<String>!
    
    fileprivate let disposeBag = DisposeBag()
    
    init (name: String) {
        self.exchangeName = Variable<String>(name)
        setup()
    }
    
    func setup () {
        exchangeTrade$ = exchangeTrade.asObservable()
        exchangeTradeLastPrice$ = exchangeTrade.asObservable()
            .map({ (trade: JSON) -> String in
                return String(format: "%.2f", trade[1][6].floatValue)
            })
        
        exchangeTx$ = exchangeTx.asObservable()
        exchangeName$ = exchangeName.asObservable()
    }
}
