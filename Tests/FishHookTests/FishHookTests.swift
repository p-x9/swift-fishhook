import XCTest
@testable import FishHook

final class FishHookTests: XCTestCase {
    override class func setUp() {
        _ = disableExclusivityChecking
    }

    func test() {
        if setjump(&buf) != 0 {
            return
        }

        guard let machO = MachOImage(name: "FishHookTests") else { return }
        guard let to = machO.symbol(
            named: "_$s13FishHookTests25XXXXhook_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_A2ISus6UInt32VtF"
        ) else {
            return
        }

        var rebindings: [Rebinding] = [
            .init(
                name: "_$ss17_assertionFailure__4file4line5flagss5NeverOs12StaticStringV_A2HSus6UInt32VtF",
                replacement: .init(mutating: machO.ptr.advanced(by: to.offset)),
                replaced: nil
            )
        ]

        FishHook.rebind_symbols_image(
            machO: machO,
            rebindings: &rebindings
        )

        var optional: Int?
        let forceUnwrapped = optional!
    }
}
