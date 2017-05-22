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
    
    @IBOutlet weak var ex1: UIButton!
    @IBOutlet weak var ex2: UIButton!
    @IBOutlet weak var ex3: UIButton!
    
    
    var profileSegue: AnyObserver<Exchange> {
        return NavigationSegue(fromViewController: self.navigationController!,
                               toViewControllerFactory: { (sender, context) -> ExchangeDetailViewController in
                                let exchangeDetailVC: ExchangeDetailViewController = StoryBoard.main
                                    .instantiateViewController()
                                exchangeDetailVC.exchange = context
                                return exchangeDetailVC
        }).asObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ex1.rx.tap
            .map {
                return Exchange(name: "Exchange One")
            }
            .bind(to: profileSegue)
            .addDisposableTo(disposeBag)
        
        ex2.rx.tap
            .map {
                return Exchange(name: "Exchange Two")
            }
            .bind(to: profileSegue)
            .addDisposableTo(disposeBag)
        
        ex3.rx.tap
            .map {
                return Exchange(name: "Exchange Three")
            }
            .bind(to: profileSegue)
            .addDisposableTo(disposeBag)
        
//        _ = createSocketObservable(address: "wss://www.bitmex.com/realtime?subscribe=quote")
//            .do(onNext: { _ in
//                print("message received")
//            })
//            .subscribe()
        
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
            .do(onNext: { val in
//                print(val)
            })
        
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
                print(": \(interval) \(total)")
                return total
            })
            .do(onNext: { (total: Int) in
                print("running total \(total)")
            })
            .subscribe()
        
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

