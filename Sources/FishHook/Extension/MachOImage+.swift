//
//  MachOImage+.swift
//
//
//  Created by p-x9 on 2024/02/03.
//  
//

import Foundation
import MachOKit

extension LoadCommandsProtocol {
    var data: SegmentCommand? {
        compactMap {
            if case let .segment(info) = $0,
               info.segmentName == SEG_TEXT { info } else { nil }
        }.first
    }

    var data64: SegmentCommand64? {
        compactMap {
            if case let .segment64(info) = $0,
               info.segmentName == SEG_DATA { info } else { nil }
        }.first
    }

    var data_const: SegmentCommand? {
        compactMap {
            if case let .segment(info) = $0,
               info.segmentName == "__DATA_CONST" { info } else { nil }
        }.first
    }

    var data_const64: SegmentCommand64? {
        compactMap {
            if case let .segment64(info) = $0,
               info.segmentName == "__DATA_CONST" { info } else { nil }
        }.first
    }
}

extension SectionProtocol {
    var address: Int {
        if let section = self as? Section64 {
            return numericCast(section.addr)
        } else if let section = self as? Section {
            return numericCast(section.addr)
        }
        return 0
    }
}
