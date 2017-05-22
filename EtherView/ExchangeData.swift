//
//  ExchangeData.swift
//  EtherView
//
//  Created by James McNamee on 22/5/17.
//  Copyright © 2017 James McNamee. All rights reserved.
//

import Foundation

struct ExchangeData {
    var name: String
    var lastPrice: Float?
    var txPerMinute: Int?
    
    init (name: String) {
        self.name = name
    }
}
