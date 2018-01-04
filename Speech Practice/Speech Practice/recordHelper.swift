//
//  recordHelper.swift
//  Speech Practice
//
//  Created by Ada on 1/3/18.
//  Copyright © 2018 yuxujian. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioSessionMode{
    case record
    case play
}


/*
 为什么要继承NSObject?
 因为下面init()方法里有行audioRecorder?.delegate = self
 我们需要服从delegate,需要服务delegate,要服protocal,那么必须是NSObject的子类,所以我们加入NSObject
 */
class RecordHelper: NSObject, AVAudioRecorderDelegate {
    var audioPlayer:AVAudioPlayer?
    var audioRecorder:AVAudioRecorder?
    var isRecord = false
    
    func record() {
        //手按下去开始录音
        settingAudioSession(toMode: .record)
        audioRecorder?.prepareToRecord()
        audioRecorder?.record()
        isRecord = true
    }
    
    
    func recordBtnRelease() {
        //放开手,录音结束
        if audioRecorder != nil {
            audioRecorder?.stop()
            isRecord = false
            settingAudioSession(toMode: .play)
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
//                audioPlayer?.stop()
//                audioPlayer?.currentTime = 0.0
//                audioPlayer?.play()
                playAudio()
            }catch{
                
            }
        }
    }
    
    func playAudio() {
        if isRecord == false {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0.0
            audioPlayer?.play()
        }
    }
    
    
    override init() {
        super.init()
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
        
    }
    
}
