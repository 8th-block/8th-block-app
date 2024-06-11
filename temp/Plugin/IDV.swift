import Foundation

@objc public class IDV: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
