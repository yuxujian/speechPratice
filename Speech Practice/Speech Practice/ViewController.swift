//
//  ViewController.swift
//  Speech Practice
//
//  Created by Ada on 1/2/18.
//  Copyright © 2018 yuxujian. All rights reserved.
//

import UIKit
import AVFoundation
import Speech


enum AudioSessionMode{
    case record
    case play
}
class ViewController: UIViewController,AVAudioRecorderDelegate, SFSpeechRecognizerDelegate {
    var audioPlayer:AVAudioPlayer?
    var audioRecorder:AVAudioRecorder?
    var isRecord = false
    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var recordBtn: UIButton!
    @IBAction func record(_ sender: UIButton) {
        //手按下去开始录音
        settingAudioSession(toMode: .record)
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
        isRecord = true
        info.isHidden = true
        recordBtn.setTitle("Recording", for: .normal)
        
        startRecording()
    }
    
    
    @IBAction func recordBtnRelease(_ sender: UIButton) {
        //放开手,录音结束
        if audioRecorder != nil {
            info.isHidden = false
            recordBtn.setTitle("Record", for: .normal)
            
            
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordBtn.isEnabled = false
            
            
            audioRecorder?.stop()
            isRecord = false
            settingAudioSession(toMode: .play)
            
        }
        
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        //如果手机摇动
        if event?.subtype == .motionShake {
            if isRecord == false {
                audioPlayer?.stop()
                audioPlayer?.currentTime = 0.0
                audioPlayer?.play()
            }
        }
    }
    
    func settingAudioSession(toMode mode:AudioSessionMode) {
        audioPlayer?.stop()
        
        let session = AVAudioSession.sharedInstance()
        do {
            switch mode {
            case .record:
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            case .play:
                //try session.setCategory(AVAudioSessionCategoryPlayback)
                try session.setCategory(AVAudioSessionCategoryAmbient)
            }
            
            try session.setActive(false)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag == true {
            
            do{
                audioPlayer = try AVAudioPlayer(contentsOf: recorder.url)
                audioPlayer?.stop()
                audioPlayer?.currentTime = 0.0
                audioPlayer?.play()
            }catch{
                
            }
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
        //init an audio recorder
        let fileName = "user.wav"
        let path = NSHomeDirectory() + "/Documents/" + fileName
        let url = URL(fileURLWithPath: path)
        let recordSetting:[String:Any] = [
            AVEncoderAudioQualityKey:AVAudioQuality.min.rawValue,
            AVEncoderBitRateKey:16,
            AVNumberOfChannelsKey:2,
            AVSampleRateKey:44100.0
            
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recordSetting)
            audioRecorder?.delegate = self
        } catch  {
            print(error.localizedDescription)
        }
        
        
        
        
        
        
        
        
        
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

