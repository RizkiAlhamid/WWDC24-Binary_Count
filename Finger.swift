import SwiftUI

struct Finger {
    var name: Name
    var tip: CGPoint
    var dip: CGPoint
    var hand: Hand
    
    enum Hand {
        case left
        case right
    }
    enum Name {
        case thumb
        case index
        case middle
        case ring
        case little
    }
    
    func isRaised() -> Bool {
        let collisionTrigger = 0.03
        switch self.name {
        case .thumb:
            if (hand == .right && tip.x > dip.x) || (hand == .left && tip.x < dip.x) { return true }
        default:
            if (tip.y > dip.y && tip.distance(from: dip) > collisionTrigger) {
                return true
            }
        }
        return false
    }
    
    func getBinaryValue() -> Int {
        var value: Int
        switch self.name {
        case .thumb:
            value = (hand == .right) ? 1 : 512
        case .index:
            value = (hand == .right) ? 2 : 256
        case .middle:
            value = (hand == .right) ? 4 : 128
        case .ring:
            value = (hand == .right) ? 8 : 64
        case .little:
            value = (hand == .right) ? 16 : 32
        }
        return value
    }
    static let targetNumbersCollection: [Int] = [
        0, 1, 2, 3, 4, 5, 6, 7, 14, 15, 18, 19, 25, 26, 27, 28, 29, 30, 31, 256, 257, 512, 513, 1022, 1023
    ]
}

extension CGPoint {
    
    func distance(from point: CGPoint) -> CGFloat {
        return hypot(point.x - x, point.y - y)
    }
}
