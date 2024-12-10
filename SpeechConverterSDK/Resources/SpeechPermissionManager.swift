//
//  SpeechPermissionManager.swift
//  
//
//  Created by VietCredit on 10/12/24.
//

import Foundation
import AVFoundation
import Speech

public class SpeechPermissionManager {
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            let speechAuthorized = (authStatus == .authorized)
            
            AVAudioSession.sharedInstance().requestRecordPermission { audioAuthorized in
                DispatchQueue.main.async {
                    completion(speechAuthorized && audioAuthorized)
                }
            }
        }
    }
}
