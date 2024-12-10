//
//  AudioRecorder.swift
//
//
//  Created by VietCredit on 10/12/24.
//

import AVFoundation

class AudioRecorder {
    private var audioEngine = AVAudioEngine()
    private var audioInputNode: AVAudioInputNode?
    
    func startRecording() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        audioInputNode = audioEngine.inputNode
        let recordingFormat = audioInputNode!.outputFormat(forBus: 0)
        audioInputNode!.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            // Process the audio buffer
        }
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioInputNode?.removeTap(onBus: 0)
    }
}
