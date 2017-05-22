//
//  SocketObservable.swift
//  EtherView
//
//  Created by James McNamee on 22/5/17.
//  Copyright © 2017 James McNamee. All rights reserved.
//

import UIKit
import RxSwift
import RxStarscream
import Starscream

struct SocketMessage {
    var status: String?
    var message: String?
    var socket: WebSocket?
    
    init (status: String) {
        self.status = status
    }
    
    init (status: String, socket: WebSocket) {
        self.status = status
        self.socket = socket
    }
    
    init (status: String, message: String) {
        self.status = status
        self.message = message
    }
}

func createSocketObservable (address url: String) -> Observable<SocketMessage> {

    let socket = WebSocket(url: URL(string: url)!)
    return Observable.create { observer in
        
        _ = socket.rx.response.subscribe(onNext: { (response: WebSocketEvent) in
            switch response {
            case .connected:
                observer.on(.next(SocketMessage(status: "Connected", socket: socket)))
            case .disconnected(let error):
                print("Disconnected with optional error : \(String(describing: error))")
                observer.on(.next(SocketMessage(status: "Disconnected")))
                observer.on(.completed)
            case .message(let msg):
                observer.on(.next(SocketMessage(status: "Connected", message: msg)))
            case .data(_):
                print("Data")
            case .pong:
                print("Pong")
            }
        })
        
        socket.connect()
        
        return Disposables.create()
    }
}
