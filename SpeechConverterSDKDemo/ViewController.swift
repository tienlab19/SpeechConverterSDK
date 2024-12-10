//
//  ViewController.swift
//  SpeechConverterSDKDemo
//
//  Created by VietCredit on 10/12/24.
//

import UIKit
import SpeechConverterSDK

class ViewController: UIViewController {
    
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    
    var isRecord: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        self.recordButton.setTitle("Start Record", for: .normal)
    }
    
    @IBAction private func onRecordTap(_ sender: UIButton) {
        self.isRecord.toggle()
        if self.isRecord {
            self.recordButton.setTitle("Stop Record", for: .normal)
            SpeechConverterSDK.shared.startSpeechToText { response in
                self.textLabel.text = response
            }
        } else {
            self.recordButton.setTitle("Start Record", for: .normal)
            SpeechConverterSDK.shared.stopSpeechToText()
        }
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
