//
//  VoiceRe_ViewController.swift
//  Stickapp
//
//  Created by 早坂彪流 on 2016/04/10.
//  Copyright © 2016年 takeru haysaka. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class VoiceRe_ViewController: UIViewController,OEEventsObserverDelegate{

    @IBOutlet weak var voiceCmd_button: UIButton!
    @IBOutlet weak var UpAction_button: UIButton!
    @IBOutlet weak var lightAction_button: UIButton!
    @IBOutlet weak var reftAction_button: UIButton!
    @IBOutlet weak var DownAction_button: UIButton!
    
    //OpenEars オブジェクト
    var slt:Slt!//音声合成
    
    var openEarsEventsObserver:OEEventsObserver!//OpenEarsのイベント通知クラス
    var pocketsphinxController:OEPocketsphinxController!//音声認識クラス
    var fliteController:OEFliteController!//音声合成
    //
    var resorcePath:String!
    var amPath:String!
    var lmPath:String!
    var dicPath:String!
    
    @IBOutlet weak var VoiceCmdEvent_button: UIButton!
    
    
    // Some UI, not specifically related to OpenEars.
    var usingStartingLanguageModel:Bool!
    var restartAttemptsDueToPermissionRequests:Int!
    
    var startupFailedDueToLackOfPermissions:Bool!
    
    //動的言語機能を披露する私たちを助けるもの。
    var pathToFirstDynamicallyGeneratedLanguageModel:String!
    var pathToFirstDynamicallyGeneratedDictionary:String!
    var pathToSecondDynamicallyGeneratedLanguageModel:String!
    var pathToSecondDynamicallyGeneratedDictionary:String!
    
    //読むと、入力を表示および UI をロックすることがなくレベルを出力させていただきます私たち NSTimer
    var uiUpdateTimer:NSTimer!
    
    let kLevelUpdatesPerSecond = 18// We'll have the ui update 18 times a second to show some fluidity without hitting the CPU too hard.
    func INITERS(){
        self.VoiceCmdEvent_button.addTarget(self, action: #selector(VoiceRe_ViewController.startListening(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        //self.stopbutton.addTarget(self, action: #selector(VoiceRe_ViewController.stopListening(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.resorcePath = NSBundle.mainBundle().resourcePath
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        INITERS()
        self.fliteController = OEFliteController()
        self.openEarsEventsObserver = OEEventsObserver()
        self.openEarsEventsObserver.delegate = self
        self.slt = Slt()
        
        self.restartAttemptsDueToPermissionRequests = 0
        self.startupFailedDueToLackOfPermissions = false
        
        OELogging.startOpenEarsLogging()
        
        // OEPocketsphinxController.sharedInstance().verbosePocketSphinx = true
        
        do{
            try OEPocketsphinxController.sharedInstance().setActive(true)// OE Pocketsphinxコントローラーの特性を設定する前に、これを呼び出します
        }catch{
            print("OEPocketsphinxController is Error")
        }
        
        let languageModelGenerator = OELanguageModelGenerator()
        
        let firstLanguageArray = ["BACKWARD","CHANGE","FORWARD","GO","LEFT","MODEL","RIGHT","TURN","KUSONEMI"]
        self.amPath = OEAcousticModel.pathToModel("AcousticModelEnglish")
        
        var error:NSError! = languageModelGenerator.generateLanguageModelFromArray(firstLanguageArray, withFilesNamed: "FirstOpenEarsDynamicLanguageModel", forAcousticModelAtPath: self.amPath)
        if error != nil {
            print("Dynamic language generator reported error::\(error.description)")
        }else{
            self.pathToFirstDynamicallyGeneratedLanguageModel = languageModelGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName("FirstOpenEarsDynamicLanguageModel")
            self.pathToFirstDynamicallyGeneratedDictionary = languageModelGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName("FirstOpenEarsDynamicLanguageModel")
        }
        
        self.usingStartingLanguageModel = true;
        let secondLanguageArray = ["SUNDAY","MONDAY","TUESDAY","WEDNESDAY","THURSDAY","FRIDAY","SATURDAY","QUIDNUNC","CHANGE MODEL"]
        
        error = languageModelGenerator.generateLanguageModelFromArray(secondLanguageArray, withFilesNamed: "SecondOpenEarsDynamicLanguageModel", forAcousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"))
        
        if error != nil{
            print("Dynamic language generator reported error\(error.description)")
        }else{
            self.pathToSecondDynamicallyGeneratedLanguageModel = languageModelGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName("SecondOpenEarsDynamicLanguageModel")
            self.pathToSecondDynamicallyGeneratedDictionary = languageModelGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName("SecondOpenEarsDynamicLanguageModel")
            do{
                try! OEPocketsphinxController.sharedInstance().setActive(true)
            }
            if OEPocketsphinxController.sharedInstance().isListening{
                //             OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath:self.amPath , languageModelIsJSGF: false)
                //OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath:self.amPath , languageModelIsJSGF: false)
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //たとえば、NSTimer を使用して UI をロックすることがなくオーディオの入力レベルを読む
    func startDisplayingLevels(){}
    func stopDisplayingLevels(){}
    
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        print("(The received hypothesis is \(hypothesis) with a score of \(recognitionScore) and an ID of \(utteranceID)")
        //  dataLabel.text = " \(hypothesis) : \(recognitionScore) : \(utteranceID)"
    }
    func startListening(sender:UIButton!){
        if !OEPocketsphinxController.sharedInstance().isListening{
            //   OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(self.pathToSecondDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToSecondDynamicallyGeneratedDictionary, acousticModelAtPath:self.amPath , languageModelIsJSGF: false)
            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(self.pathToFirstDynamicallyGeneratedLanguageModel, dictionaryAtPath: self.pathToFirstDynamicallyGeneratedDictionary, acousticModelAtPath:self.amPath , languageModelIsJSGF: false)
        }
        
        // self.pocketsphinxController.startListeningWithLanguageModelAtPath(self.lmPath, dictionaryAtPath: self.dicPath, acousticModelAtPath: self.amPath, languageModelIsJSGF: false)
    }
    func stopListening(sender:UIButton!){
        if OEPocketsphinxController.sharedInstance().isListening{
            OEPocketsphinxController.sharedInstance().stopListening()
        }
    }


}
