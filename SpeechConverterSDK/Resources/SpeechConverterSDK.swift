//
//  SpeechConverterSDK.swift
//
//
//  Created by VietCredit on 10/12/24.
//

import Foundation

public class SpeechConverterSDK: NSObject {
    
    static public let shared = SpeechConverterSDK()
    
    private let permissionManager = SpeechPermissionManager()
    private let audioRecorder = AudioRecorder()
    private let speechRecognizer = SpeechRecognizer()
    
    public func startSpeechToText(completion: @escaping (String?) -> Void) {
        permissionManager.requestPermissions { granted in
            guard granted else {
                completion(nil)
                return
            }
            do {
                try self.audioRecorder.startRecording()
                self.speechRecognizer.startRecognition { recognizedText in
                    print("[SDK DEUG] recognizedText: \(recognizedText ?? "")")
                    completion(self.convertToFormattedCurrency(in: recognizedText ?? ""))
                }
            } catch {
                print("Recording Error: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    public func stopSpeechToText() {
        audioRecorder.stopRecording()
        speechRecognizer.stopRecognition()
    }
    
    private func convertToFormattedCurrency(in text: String) -> String {
        // Regex để tìm số, bao gồm cả dấu chấm và dấu cách làm phân cách
        let pattern = "\\d+(?:[\\.\\s]\\d+)*"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return text // Trả về chuỗi gốc nếu regex không hợp lệ
        }
        
        let range = NSRange(location: 0, length: text.utf16.count)
        var newText = text
        let matches = regex.matches(in: text, options: [], range: range).reversed() // Đảo ngược thứ tự để thay thế an toàn
        
        for match in matches {
            guard let matchRange = Range(match.range, in: text) else { continue }
            
            // Lấy số đã khớp và loại bỏ các dấu phân cách
            let matchedNumber = text[matchRange].replacingOccurrences(of: "[\\.\\s]", with: "", options: .regularExpression)
            
            if let number = Double(matchedNumber) {
                let formattedNumber = formatCurrency(amount: number)
                // Thay thế số đã khớp trong chuỗi
                newText.replaceSubrange(matchRange, with: formattedNumber)
            }
        }
        return newText
    }
    
    func formatCurrency(amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "vi-VN") // Set Vietnamese locale
        return formatter.string(from: NSNumber(value: amount)) ?? "₫0"
    }
}
