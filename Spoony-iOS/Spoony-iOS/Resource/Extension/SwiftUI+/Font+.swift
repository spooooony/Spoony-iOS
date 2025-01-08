//
//  Font+.swift
//  SpoonMe
//
//  Created by 이명진 on 1/3/25.
//

import SwiftUI

public extension Font {
    static var title1b: Font {
        return font(.pretendardBold, ofSize: 20)
    }
    
    static var title2b: Font {
        return font(.pretendardBold, ofSize: 18)
    }
    
    static var title2sb: Font {
        return font(.pretendardSemiBold, ofSize: 18)
    }
    
    static var body1b: Font {
        return font(.pretendardBold, ofSize: 16)
    }
    
    static var body1sb: Font {
        return font(.pretendardSemiBold, ofSize: 16)
    }
    
    static var body1m: Font {
        return font(.pretendardMedium, ofSize: 16)
    }
    
    static var body2b: Font {
        return font(.pretendardBold, ofSize: 14)
    }
    
    static var body2sb: Font {
        return font(.pretendardSemiBold, ofSize: 14)
    }
    
    static var body2m: Font {
        return font(.pretendardMedium, ofSize: 14)
    }
    
    static var caption1b: Font {
        return font(.pretendardBold, ofSize: 12)
    }
    
    static var caption1m: Font {
        return font(.pretendardMedium, ofSize: 12)
    }
    
    static var caption2b: Font {
        return font(.pretendardBold, ofSize: 10)
    }
    
    static var caption2m: Font {
        return font(.pretendardMedium, ofSize: 10)
    }
}

public extension Font {
    private static func font(_ style: FontName, ofSize size: CGFloat) -> Font {
        return Font.custom(style.rawValue, size: size)
    }
}
