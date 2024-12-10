//
//  SpeechRecognizer.swift
//
//
//  Created by VietCredit on 10/12/24.
//

import Speech

class SpeechRecognizer {
    private lazy var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "vi-VI"))
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let audioEngine = AVAudioEngine()
    let audioSession = AVAudioSession.sharedInstance()
    
    func startRecognition(completion: @escaping (String?) -> Void) {
        // Reset task and audio session
        resetRecognitionTask()
        
        // Ensure that speech recognizer is available
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            print("[SDK DEUG] Ensure that speech recognizer is available")
            completion(nil)
            return
        }
         
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            completion(nil)
            fatalError("Unable to create a recognition request")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Setup the recognition task
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let newTranscription = result.bestTranscription.formattedString
                completion(newTranscription)
            }
            
            // Stop recognition if an error occurs or the transcription finishes
            if error != nil || result?.isFinal == true {
                self.stopRecognition()
                print("[SDK DEUG] Stop recognition if an error occurs or the transcription finishes: \(String(describing: error?.localizedDescription))")
                completion(nil)
            }
        }
        
        // Start the audio engine
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("[SDK DEUG] Audio engine couldn't start due to error: \(error.localizedDescription)")
            completion(nil)
        }
    }
    
    func stopRecognition() {
        // Stop and reset the audio engine
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // End the recognition request and cancel the task
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    private func resetRecognitionTask() {
        // Stop the audio engine and recognition task cleanly
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Ensure the audio engine is stopped and input taps are removed
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        recognitionRequest = nil
    }
}

