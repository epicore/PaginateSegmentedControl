//
//  ViewController.swift
//  PaginateSegmentedControl
//
//  Created by Joshua Weinberg on 8/13/17.
//  Copyright © 2017 3rd Street Apps. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {
    
    let numberOfSegments = 2
    let selectedIndicie = 1
    let appleSpeech = AVSpeechSynthesizer()
    let englishVoices = AVSpeechSynthesisVoice.speechVoices().filter {
        $0.language.contains("en")
        }
    let segmentData:[String] = AVSpeechSynthesisVoice.speechVoices().filter {
        $0.language.contains("en")
        }.map ({
            $0.name.replacingOccurrences(of:" (Enhanced)", with: "+", options: NSString.CompareOptions.literal, range: nil)
        })

    @IBOutlet weak var voiceLbl: UILabel?
    @IBOutlet weak var feedbackLbl: UILabel?
    @IBOutlet weak var voicesSegCntrl: PaginateSegmentedControl?
    @IBAction func segmentValueChanged(_ sender: PaginateSegmentedControl) {
        let voice = self.englishVoices[sender.selectedSegmentIndex]
        let utterence = "Hi, I'm \(voice.name). I love you very much!"
        self.feedbackLbl?.text = utterence
        self.speakUtterence(utterence, withVoice:voice)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateVoicesSegmentControl()
    }
    
    func speakUtterence(_ str:String, withVoice voice:AVSpeechSynthesisVoice) {
        let utterance = AVSpeechUtterance(string: str)
        utterance.voice = voice
        self.appleSpeech.speak(utterance)
    }

    func updateVoicesSegmentControl() {
        self.voicesSegCntrl?.configure(withData: self.segmentData, numberOfSegments:self.numberOfSegments, andSelectedIndicie:self.selectedIndicie )
    }
}

