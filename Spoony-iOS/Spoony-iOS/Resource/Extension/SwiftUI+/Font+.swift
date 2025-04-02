//
//  Font+.swift
//  SpoonMe
//
//  Created by 이명진 on 1/3/25.
//

import SwiftUI

public extension Font {
    static var title1: Font {
        return font(.pretendardBold, ofSize: 24.adjusted)
    }
    
    static var title2: Font {
        return font(.pretendardBold, ofSize: 20.adjusted)
    }
    
    static var title3b: Font {
        return font(.pretendardBold, ofSize: 18.adjusted)
    }
    
    static var title3sb: Font {
        return font(.pretendardSemiBold, ofSize: 18.adjusted)
    }
    
    static var body1b: Font {
        return font(.pretendardBold, ofSize: 16.adjusted)
    }
    
    static var body1sb: Font {
        return font(.pretendardSemiBold, ofSize: 16.adjusted)
    }
    
    static var body1m: Font {
        return font(.pretendardMedium, ofSize: 16.adjusted)
    }
    
    static var body2b: Font {
        return font(.pretendardBold, ofSize: 14.adjusted)
    }
    
    static var body2sb: Font {
        return font(.pretendardSemiBold, ofSize: 14.adjusted)
    }
    
    static var body2m: Font {
        return font(.pretendardMedium, ofSize: 14.adjusted)
    }
    
    static var caption1b: Font {
        return font(.pretendardBold, ofSize: 12.adjusted)
    }
    
    static var caption1m: Font {
        return font(.pretendardMedium, ofSize: 12.adjusted)
    }
    
    static var caption2b: Font {
        return font(.pretendardBold, ofSize: 10.adjusted)
    }
    
    static var caption2m: Font {
        return font(.pretendardMedium, ofSize: 10.adjusted)
    }
}

public extension Font {
    private static func font(_ style: FontName, ofSize size: CGFloat) -> Font {
        return Font.custom(style.rawValue, size: size)
    }
}
