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
    
    var exchangeTrade = Variable<JSON>(JSON(0))
    var exchangeTrade$: Observable<String>!
    
    var exchangeTx = Variable<Int>(0)
    var exchangeTx$: Observable<Int>!
    
    var exchangeName = Variable<String>("")
    var exchangeName$: Observable<String>!
    
    fileprivate let disposeBag = DisposeBag()
    
    init (name: String) {
        self.exchangeName = Variable<String>(name)
        setup()
    }
    
    func setup () {
        exchangeTrade$ = exchangeTrade.asObservable()
//            .do(onNext: { val in
//                print("val \(val)")
//            })
            .map({ (trade: JSON) -> String in
                print(trade[1][6].floatValue)
                return String(format: "%.2f", trade[1][6].floatValue)
            })
        
        exchangeTx$ = exchangeTx.asObservable()
        exchangeName$ = exchangeName.asObservable()
    }
}
