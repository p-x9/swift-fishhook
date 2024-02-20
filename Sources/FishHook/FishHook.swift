@_exported import MachOKit

var rebindingsEntry: [RebindingsEntry] = []

public enum FishHook {
    @inline(__always)
    public static func rebind_symbols_image(
        machO: MachOImage,
        rebindings: [Rebinding]
    ) {
        prepend_rebindings(&rebindingsEntry, rebindings: rebindings)
        rebind_symbols_for_image(&rebindingsEntry, machO: machO)
    }

    @inline(__always)
    public static func rebind_symbols(
        rebindings: [Rebinding]
    ) {
        prepend_rebindings(&rebindingsEntry, rebindings: rebindings)

        if rebindingsEntry.count == 1 {
            _dyld_register_func_for_add_image { ptr, _ in
                guard let ptr else { return }
                let machO = MachOImage(ptr: ptr)
                FishHook._rebind_symbols_for_image(machO: machO)
            }
        } else {
            for i in 0 ..< _dyld_image_count() {
                let machO = MachOImage(ptr: _dyld_get_image_header(i))
                _rebind_symbols_for_image(machO: machO)
            }
        }
    }
}

extension FishHook {
    @inline(__always)
    private static func prepend_rebindings(
        _ rebindingsEntry: inout [RebindingsEntry],
        rebindings: [Rebinding]
    ) {
        rebindingsEntry.insert(.init(rebindings: rebindings), at: 0)
    }

    @inline(__always)
    private static func perform_rebinding_with_section(
        _ rebindingsEntry: inout [RebindingsEntry],
        machO: MachOImage,
        section: any SectionProtocol
    ) {
        guard let slide = machO.vmaddrSlide,
              let _indirectSymbols = machO.indirectSymbols,
              let start = section.indirectSymbolIndex,
              let count = section.numberOfIndirectSymbols else {
            return
        }

        let symbols = Array(machO.symbols)
        let indirectSymbols = Array(_indirectSymbols)[start ..< start + count]

        let bindings = slide + section.address
        let bindingsPtr = UnsafeMutablePointer<UnsafeMutableRawPointer>(
            bitPattern: bindings
        )!

    symbolLoop: for (indirectSymbolIndex, indirectSymbol) in indirectSymbols.enumerated() {
        guard let index = indirectSymbol.index else { continue }
        let symbol = symbols[index]

        for entry in rebindingsEntry {
            for rebinding in entry.rebindings {
                guard rebinding.name.withCString({ strcmp($0, symbol.nameC + 1) == 0 }) else { continue }

                let ptr = UnsafeMutableRawPointer(mutating: machO.ptr.advanced(by: symbol.offset))
                if rebinding.replaced != nil && rebinding.replacement != ptr {
                    rebinding.replaced?.pointee = ptr
                }
                let err = vm_protect(
                    mach_task_self_,
                    numericCast(bindings),
                    numericCast(section.size),
                    0,
                    VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY
                )
                if err == KERN_SUCCESS {
                    bindingsPtr
                        .advanced(by: indirectSymbolIndex).pointee = rebinding.replacement
                }
                continue symbolLoop
            }
        }
    }
    }

    @inline(__always)
    private static func rebind_symbols_for_image(
        _ rebindingsEntry: inout [RebindingsEntry],
        machO: MachOImage
    ) {
        let loadCommands = machO.loadCommands

        let sections: [any SectionProtocol]
        if machO.is64Bit {
            sections = [loadCommands.data64, loadCommands.data_const64]
                .compactMap { $0 }
                .flatMap { Array($0.sections(cmdsStart: machO.cmdsStartPtr)) as [any SectionProtocol]}
        } else {
            sections = [loadCommands.data, loadCommands.data_const]
                .compactMap { $0 }
                .flatMap { Array($0.sections(cmdsStart: machO.cmdsStartPtr)) as [any SectionProtocol]}
        }

        for section in sections {
            if [.lazy_symbol_pointers, .non_lazy_symbol_pointers].contains(section.flags.type) {
                perform_rebinding_with_section(&rebindingsEntry, machO: machO, section: section)
            }
        }
    }

    @inline(__always)
    private static func _rebind_symbols_for_image(
        machO: MachOImage
    ) {
        rebind_symbols_for_image(&rebindingsEntry, machO: machO)
    }
}
