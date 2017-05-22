//
//  ViewController.swift
//  EtherView
//
//  Created by James McNamee on 18/5/17.
//  Copyright © 2017 James McNamee. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSegue
import RxGesture
import SwiftyJSON

struct StoryBoard {
    static let main = UIStoryboard(name: "Main", bundle: nil)
}

extension UIViewController {
    class var storyboardId: String {
        return String(describing: self)
    }
}

struct Exchange {
    let name:Variable<String>
    
    init(name:String) {
        self.name = Variable(name)
    }
}

extension UIStoryboard {
    func instantiateViewController<T: UIViewController>() -> T {
        guard let viewController = instantiateViewController(withIdentifier: T.storyboardId) as? T else {
            fatalError("Cast error to \(T.self)")
        }
        return viewController
    }
}


class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var bitfinexCardView: CardView!
    
    fileprivate var exchangeViewModel: ExchangeViewModel!
    
    var profileSegue: AnyObserver<ExchangeViewModel> {
        return NavigationSegue(fromViewController: self.navigationController!,
                               toViewControllerFactory: { (sender, context) -> ExchangeDetailViewController in
                                let exchangeDetailVC: ExchangeDetailViewController = StoryBoard.main
                                    .instantiateViewController()
                                exchangeDetailVC.exchangeVM = context
                                return exchangeDetailVC
        }).asObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "EtherView"
        
        exchangeViewModel = ExchangeViewModel(name: "Bitfinex")
        bitfinexCardView.exchangeVM = exchangeViewModel
        bitfinexCardView.rx.tapGesture().when(.recognized)
            .map({ [unowned self] _ in
                return self.exchangeViewModel
            })
            .bind(to: profileSegue)
            .addDisposableTo(disposeBag)
        
        let bitfinex = createSocketObservable(address: "wss://api.bitfinex.com/ws/2").share()
        
//        bitfinex trade channel response format
//        [
//            2,
//            [
//                148.5,            // 0 bid
//                66.10374596,      // 1 bid amount
//                148.98,           // 2 ask
//                7.11585876,       // 3 ask amount
//                23.41,            // 4 24 hr change
//                0.1864,           // 5 daily change % (need to * 100)
//                148.98,           // 6 last price
//                285552.07277477,  // 7 volume
//                149.19,           // 8 high
//                123.55            // 9 low
//            ]
//        ]
        let bitfinexTrades = bitfinex
            .map({ (message: SocketMessage) -> JSON in
                if let dataFromString = message.message?.data(using: .utf8, allowLossyConversion: false) {
                    return JSON(data: dataFromString)
                }
                return JSON(0)
            })
            .filter({ obj in
                // "hb" update messages should be ignored
                return obj[1].string == nil
            })
            // filter 0 values and json objects with an event key (they are info messages)
            .filter({ $0 != 0 && $0 != "0" && !$0["event"].exists() })
            
        _ = bitfinexTrades
            .bind(to: exchangeViewModel.exchangeTrade)
            .addDisposableTo(disposeBag)
        
        // moving average of trades per minute, the 60 second window is sliding after the first minute of running
        // this is more complicated than it should be due to the limited implementation of the `window` operator in RxSwift
        let window = bitfinexTrades
            .scan(0, accumulator: { (prevCount: Int, next: JSON) -> Int in
                return prevCount + 1
            })
            .startWith(0)
            
        let withDelay = window
            .delay(RxTimeInterval(60), scheduler: MainScheduler.instance)
            .startWith(0)

        let runningTotal = Observable.combineLatest(window, withDelay, resultSelector: { (total: Int, td: Int) -> Int in
            return total - td
        })
            
        _ = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .withLatestFrom(runningTotal, resultSelector: { (interval, total) -> Int in
                return total
            })
            .bind(to: exchangeViewModel.exchangeTx)
            .addDisposableTo(disposeBag)
        
        bitfinexTrades
            .subscribe()
            .addDisposableTo(disposeBag)
        
        // take one connected message and send a subscribe message back into the socket
        _ = bitfinex
            .filter({ $0.status == "Connected" })
            .do(onNext: { (message: SocketMessage) in
                let jsonString = "{\"event\": \"subscribe\", \"channel\": \"ticker\", \"symbol\": \"tETHUSD\"}"
                message.socket?.write(string: jsonString)
            })
            .take(1)
            .subscribe()
            .addDisposableTo(disposeBag)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

