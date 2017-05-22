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
import SwiftyJSON

class ExchangeDetailViewController: UIViewController, UITableViewDelegate {
    let disposeBag = DisposeBag()
    var exchangeVM: ExchangeViewModel!
    
    @IBOutlet weak var tradeTableView: UITableView!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // only display rows that have data
        tradeTableView.tableFooterView = UIView()
        
        tradeTableView.rx.setDelegate(self)
            .addDisposableTo(disposeBag)
        
        exchangeVM.exchangeTrade$
            .map({ trade in
                return String(format: "%.2f", trade[1][7].floatValue)
            })
            .bind(to: volumeLabel.rx.text)
            .disposed(by: disposeBag)
        
        exchangeVM.exchangeTrade$
            .map({ trade in
                return String(format: "%.2f", trade[1][4].floatValue)
            })
            .bind(to: changeLabel.rx.text)
            .disposed(by: disposeBag)
        
        exchangeVM.exchangeTrade$
            .map({ trade in
                return String(format: "%.2f", trade[1][8].floatValue)
            })
            .bind(to: highLabel.rx.text)
            .disposed(by: disposeBag)
        
        _ = exchangeVM.exchangeTrade$
            .scan([]) { lastSlice, trade -> Array<String> in
                let append = String(format: "%.2f", trade[1][6].floatValue)
                return Array(
                        Array(lastSlice + [append]).suffix(10)
                    ).reversed()
            }
            .flatMap { Observable.from(optional: $0) }
            .bind(to: tradeTableView.rx.items(cellIdentifier: "TradeTableCell", cellType: TradeTableCell.self)) { (row, element, cell) in
                cell.cellData = element
            }
            .disposed(by: disposeBag)
        
    }
}
