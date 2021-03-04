import Foundation
import UIKit

struct StringConstants {
    static let lang = "jpn"
    static let inputSharpness = "inputSharpness"
    static let inputNoiseLevel = "inputNoiseLevel"
    static let noiseReductionFilterName = "CINoiseReduction"
}

struct Defaults {
    static let imageFilterThreshold: CGFloat = 0.5
    static let blurRadiusInPixels: CGFloat = 15.0
    static let inputNoiseLevel =  0.02
    static let inputSharpness = 0.40
    static let maxDimension: CGFloat = 1000
}
