//
//  UIFont+.swift
//  SpoonMe
//
//  Created by 이명진 on 1/3/25.
//

import UIKit

public extension UIFont {
    @nonobjc class var title1b: UIFont {
        return UIFont.font(.pretendardBold, ofSize: 20.adjusted)
    }
    
    @nonobjc class var title2b: UIFont {
        return UIFont.font(.pretendardBold, ofSize: 18.adjusted)
    }
    
    @nonobjc class var title2sb: UIFont {
        return UIFont.font(.pretendardSemiBold, ofSize: 18.adjusted)
    }
    
    @nonobjc class var body1b: UIFont {
        return UIFont.font(.pretendardBold, ofSize: 16.adjusted)
    }
    
    @nonobjc class var body1sb: UIFont {
        return UIFont.font(.pretendardSemiBold, ofSize: 16.adjusted)
    }
    
    @nonobjc class var body1m: UIFont {
        return UIFont.font(.pretendardMedium, ofSize: 16.adjusted)
    }
    
    @nonobjc class var body2b: UIFont {
        return UIFont.font(.pretendardBold, ofSize: 14.adjusted)
    }
    
    @nonobjc class var body2sb: UIFont {
        return UIFont.font(.pretendardSemiBold, ofSize: 14.adjusted)
    }
    
    @nonobjc class var body2m: UIFont {
        return UIFont.font(.pretendardMedium, ofSize: 14.adjusted)
    }
    
    @nonobjc class var caption1b: UIFont {
        return UIFont.font(.pretendardBold, ofSize: 12.adjusted)
    }
    
    @nonobjc class var caption1m: UIFont {
        return UIFont.font(.pretendardMedium, ofSize: 12.adjusted)
    }
    
    @nonobjc class var caption2b: UIFont {
        return UIFont.font(.pretendardBold, ofSize: 10.adjusted)
    }
    
    @nonobjc class var caption2m: UIFont {
        return UIFont.font(.pretendardMedium, ofSize: 10.adjusted)
    }
}

public enum FontName: String {
    case pretendardBold = "Pretendard-Bold"
    case pretendardSemiBold = "Pretendard-SemiBold"
    case pretendardMedium = "Pretendard-Medium"
}

public extension UIFont {
    static func font(_ style: FontName, ofSize size: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: style.rawValue, size: size) else {
            print("🍎 \(style.rawValue) font 가 제대로 등록되지 않았다는 메세지 임 🍎")
            return UIFont.systemFont(ofSize: size)
        }
        return customFont
    }
}
