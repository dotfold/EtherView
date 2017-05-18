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

struct StoryBoard {
    static let main = UIStoryboard(name: "Main", bundle: nil)
}

extension UIViewController {
    class var storyboardId: String {
        return String(describing: self)
    }
}

struct Exchange {
    var name: String?
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
    
    @IBOutlet weak var detailButton: UIButton!
    
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
        
        detailButton.rx.tap
            .map {
                return Exchange(name: "John Doe")
            }
            .bind(to: profileSegue)
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

