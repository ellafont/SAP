//
//  token.swift
//  sap
//
//  Created by Isabella Shaw on 5/7/19.
//  Copyright © 2019 Allie Smith. All rights reserved.
//

import Foundation

struct Token{
    let type: TokenType
    let intValue: Int?
    let stringValue: String?
    let tupleValue: Tuple?
    
    init(type: TokenType, intValue: Int?, stringValue: String?, tupleValue: Tuple?) {
        self.type = type
        self.intValue = intValue
        self.stringValue = stringValue?.replacingOccurrences(of: "\"", with: "")
        self.tupleValue = tupleValue
    }
}



