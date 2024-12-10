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
                    completion(recognizedText)
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
}
