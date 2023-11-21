//
//  String+.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/10.
//

import Foundation
import UIKit
import RxSwift
import RxGesture
import RxCocoa

extension String {
    func toDate() -> Date? { //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
    
    func replaceString(where contains: String, of target: String, with replace: String) -> String {
        let replaceString = self.contains("\(contains)") ?
        self.replacingOccurrences(of: target, with: replace) : self
        
        return replaceString
    }
    
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter.string(from: self)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    var appOffset: CGFloat {
        return UIScreen.main.bounds.width / 50
    }
    
    func setGradient(startColor: UIColor, endColor: UIColor, startPoint: CGPoint, endPoint: CGPoint) {
        let gradient = CAGradientLayer()
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }
    
    
}

extension Int {
    func millisecondsToTimeString() -> String {
        let totalSeconds = self / 1000
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        
        return timeString
    }
    
}

extension UILabel {
    func isTruncated() -> Bool {
        guard let labelText = text else { return false }
        
        let textRect = CGSize(width: frame.size.width, height: .greatestFiniteMagnitude)
        let labelSize = (labelText as NSString)
            .boundingRect(with: textRect,
                          options: .usesLineFragmentOrigin,
                          attributes: [.font: font],
                          context: nil)
        
        return labelSize.height >= font.lineHeight 
    }
    
    // label의 폰트, 사이즈를 계산해서 최종적으로 화면에 보여질 글자의 길이
    var visibleTextLength: Int {
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude) // Label의 크기
        
        if let myText = self.text {
            
            let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
            let attributedText = NSAttributedString(
                string: myText,
                attributes: attributes as? [NSAttributedString.Key: Any])
            
            let boundingRect: CGRect = attributedText.boundingRect(
                with: sizeConstraint,
                options: .usesLineFragmentOrigin,
                context: nil)
            
            if boundingRect.size.height > labelHeight {
                var index: Int = 0
                var prev: Int = 0
                let characterSet = CharacterSet.whitespacesAndNewlines
                repeat {
                    prev = index
                    if mode == NSLineBreakMode.byCharWrapping {
                        index += 1
                    } else {
                        index = (myText as NSString).rangeOfCharacter(
                            from: characterSet,
                            options: [],
                            range: NSRange(
                                location: index + 1,
                                length: myText.count - index - 1)).location
                    }
                } while index != NSNotFound && index < myText.count && (myText as NSString)
                    .substring(to: index)
                    .boundingRect(
                        with: sizeConstraint,
                        options: .usesLineFragmentOrigin,
                        attributes: attributes as? [NSAttributedString.Key: Any], context: nil)
                    .size
                    .height <= labelHeight
                
                return prev
            }
        }
        
        if self.text == nil {
            return 0
        } else {
            return self.text!.count
        }
    }
    
    // Label에 "... 더보기"와 같은 텍스트를 추가하기 위한 함수
    func addTrailing(
        with trailingText: String,
        moreText: String,
        moreTextFont: UIFont,
        moreTextColor: UIColor
    ) {
        
        let readMoreText: String = trailingText + moreText
        
        if self.visibleTextLength == 0 { return }
        
        let lengthForVisibleString: Int = self.visibleTextLength
        
        if let myText = self.text {
            
            let mutableString: String = myText
            let trimmedString: String? = (mutableString as NSString).replacingCharacters(
                in: NSRange(
                    location: lengthForVisibleString,
                    length: myText.count - lengthForVisibleString
                ), with: "")
            
            let readMoreLength: Int = (readMoreText.count)
            
            guard let safeTrimmedString = trimmedString else { return }
            
            if safeTrimmedString.count <= readMoreLength { return }
            
            let trimmedForReadMore: String = (safeTrimmedString as NSString)
                .replacingCharacters(
                    in: NSRange(
                        location: safeTrimmedString.count - readMoreLength,
                        length: readMoreLength)
                    ,with: ""
                ) + trailingText
            
            let answerAttributed = NSMutableAttributedString(
                string: trimmedForReadMore,
                attributes: [NSAttributedString.Key.font: self.font as Any]
            )
            
            let readMoreAttributed = NSMutableAttributedString(
                string: moreText,
                attributes: [NSAttributedString.Key.font: moreTextFont,
                             NSAttributedString.Key.foregroundColor: moreTextColor]
            )
            answerAttributed.append(readMoreAttributed)
            self.attributedText = answerAttributed
        }
    }

}

extension UITextView {
    func numberOfLine() -> Int {
        
        let size = CGSize(width: frame.width, height: .infinity)
        let estimatedSize = sizeThatFits(size)
        
        return Int(estimatedSize.height / (self.font!.lineHeight))
    }
}
