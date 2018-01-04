//
//  ViewController.swift
//  Speech Practice
//
//  Created by Ada on 1/2/18.
//  Copyright © 2018 yuxujian. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate,UIPickerViewDataSource, UIPickerViewDelegate {
    
    var recordHelper:RecordHelper?
    
    var selectedLanguage:String = "en-US"
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var languagePV: UIPickerView!
    let languages = ["English","Traditional","Simplified"]
    
    
    
    //显示1个components
    func numberOfComponents(in pickerView:UIPickerView) -> Int {
        return 1
    }
    
    //显示多少行
    func pickerView(_ pickerView:UIPickerView, numberOfRowsInComponent component:Int) -> Int {
        return languages.count
    }
    
    //显示内容
    func pickerView(_ PickerView:UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return languages[row]
    }
    
    //用户选择的内容
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(languages[row])
        var language = getSelectCode(selectedLanguage: languages[row])
        //print(language)
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: language))!
        
    }
    
    func getSelectCode(selectedLanguage:String) -> String {
            switch(selectedLanguage) {
            case "English"  :
                return "en_US"
            case "Traditional"  :
                return "zh_Hant_HK"
            case "Simplified" :
                return "zh_Hans_SG"
            default :
                return "en_US";
            }
    }

    
    @IBAction func record(_ sender: UIButton) {
        recordBtn.setTitle("Recording", for: .normal)
        recordHelper?.record()
        
        info.isHidden = true
        startRecording()
    }
    
    
    @IBAction func recordBtnRelease(_ sender: UIButton) {
            info.isHidden = false
            recordBtn.setTitle("Record", for: .normal)
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordBtn.isEnabled = false
            recordHelper?.recordBtnRelease()

    }
    
    
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        //如果手机摇动
        if event?.subtype == .motionShake {
            recordHelper?.playAudio()
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        let inputNode = audioEngine.inputNode
        
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString  //9
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordBtn.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        //textView.text = "Tip: Shaking your cell phone will replay."
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordBtn.isEnabled = true
        } else {
            recordBtn.isEnabled = false
        }
    }
    
    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        recordHelper = RecordHelper()
        
        
        recordBtn.isEnabled = false
        speechRecognizer.delegate = self
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.recordBtn.isEnabled = isButtonEnabled
            }
        }
        
    }

}

