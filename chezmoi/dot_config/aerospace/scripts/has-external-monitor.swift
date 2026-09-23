import CoreGraphics
import Darwin

let maximumDisplayCount: UInt32 = 32
var displays = [CGDirectDisplayID](repeating: 0, count: Int(maximumDisplayCount))
var displayCount: UInt32 = 0

let result = CGGetActiveDisplayList(maximumDisplayCount, &displays, &displayCount)
guard result == .success else {
    fputs("CGGetActiveDisplayList failed: \(result.rawValue)\n", stderr)
    exit(2)
}

let hasExternalDisplay = displays.prefix(Int(displayCount)).contains {
    CGDisplayIsBuiltin($0) == 0
}

print(hasExternalDisplay ? "true" : "false")
exit(hasExternalDisplay ? 0 : 1)
