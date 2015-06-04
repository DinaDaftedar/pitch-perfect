//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Dina Daftedar on 5/27/15.
//  Copyright (c) 2015 Dina Daftedar. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation



class PlaySoundsViewController: UIViewController {
   
    var audioPlayer:AVAudioPlayer!
    var echoAudioPlayer:AVAudioPlayer!
    var receivedAudio:RecordedAudio!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    var reverbPlayers:[AVAudioPlayer]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        var error:NSError?
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: &error)
        audioPlayer.enableRate = true
        audioPlayer.volume = 1.0

        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        
        echoAudioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: &error)
        
        //reverb array players
        reverbPlayers = []
    }

    @IBAction func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
        
        var pitchPlayer = AVAudioPlayerNode()
        audioEngine.attachNode(pitchPlayer)
        
        var timePitch = AVAudioUnitTimePitch()
        timePitch.pitch = pitch
        audioEngine.attachNode(timePitch)
        
        audioEngine.connect(pitchPlayer, to: timePitch, format: nil)
        audioEngine.connect(timePitch, to: audioEngine.outputNode, format:nil)
        
        pitchPlayer.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        
        pitchPlayer.play()
    }
    
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-10000)
    }
    
    func playerSettings(playRate: Float) {
        audioPlayer.stop()
        audioPlayer.rate = playRate
        audioPlayer.currentTime = 0.0
        audioPlayer.play()
    }
    
    @IBAction func playSlowSound(sender: UIButton) {
        playerSettings(0.5)
    }
    
    @IBAction func playFastSound(sender: UIButton) {
        playerSettings(1.5)
    }
    
    @IBAction func stopAnySound(sender: UIButton) {
        audioPlayer.stop()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func playEcho(sender: UIButton) {
        audioPlayer.stop()
        audioPlayer.currentTime = 0;
        audioPlayer.play()
        
        
        let delay:NSTimeInterval = 0.5//100ms
        var playtime:NSTimeInterval
        playtime = echoAudioPlayer.deviceCurrentTime + delay
        echoAudioPlayer.stop()
        echoAudioPlayer.currentTime = 0
        echoAudioPlayer.volume = 0.8;
        echoAudioPlayer.playAtTime(playtime)
    }
    
    
    @IBAction func playReverb(sender: UIButton) {
        /*
        20ms produces detectable delays
        */
        let N:Int = 10
        let delay:NSTimeInterval = 0.02
        for i in 0...N {
            reverbPlayers.append(AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil))
            var curDelay:NSTimeInterval = delay*NSTimeInterval(i)
            var player:AVAudioPlayer = reverbPlayers[i]
            //M_E is e=2.718...
            //dividing N by 2 made it sound ok for the case N=10
            var exponent:Double = -Double(i)/Double(N/2)
            var volume = Float(pow(Double(M_E), exponent))
            player.volume = volume
            player.playAtTime(player.deviceCurrentTime + curDelay)
        }
    }

}
