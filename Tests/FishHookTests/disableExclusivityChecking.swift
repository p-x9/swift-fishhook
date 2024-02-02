//
//  disableExclusivityChecking.swift
//  
//
//  Created by p-x9 on 2024/02/03.
//  
//

import Foundation

// ref: https://github.com/johnno1962/Fortify/blob/1473a1c4e35c4fbb3a5c5c70563e7721964b91a1/Sources/Fortify.swift#L99
let disableExclusivityChecking: () = {
    if let stdlibHandle = dlopen(nil, Int32(RTLD_LAZY | RTLD_NOLOAD)),
       let disableExclusivity = dlsym(stdlibHandle, "_swift_disableExclusivityChecking") {
        disableExclusivity.assumingMemoryBound(to: Bool.self).pointee = true
    }
    else {
        NSLog("Could not disable exclusivity, failure likely...")
    }
}()
