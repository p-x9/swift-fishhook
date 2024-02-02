//
//  RebindingsEntry.swift
//  
//
//  Created by p-x9 on 2024/02/03.
//  
//

import Foundation

struct RebindingsEntry {
    var rebindings: [Rebinding]
    var size: Int {
        rebindings.count
    }
}
