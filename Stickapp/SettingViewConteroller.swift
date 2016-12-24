//
//  SettingViewConteroller.swift
//  Stickapp
//
//  Created by 早坂彪流 on 2016/04/14.
//  Copyright © 2016年 takeru haysaka. All rights reserved.
//


class SettingViewConteroller: UIViewController,UITextFieldDelegate{

    @IBOutlet weak var IPAddress_textfield: UITextField!
    
    @IBOutlet weak var SendToTEL_textfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IPAddress_textfield.delegate = self
        SendToTEL_textfield.delegate = self
        IPAddress_textfield.tag = 1
        SendToTEL_textfield.tag = 2
        self.view.endEditing(true)
        
        // 「ud」というインスタンスをつくる。
        let ud = NSUserDefaults.standardUserDefaults()
        
        // キーがidの値をとります。
        var keyforTEL : AnyObject! = ud.objectForKey("TEL")
        var keyforIP : AnyObject! = ud.objectForKey("IP")
        if keyforTEL == nil{
            keyforTEL = ""
        }
        if keyforIP == nil{
            keyforIP = ""
        }
        IPAddress_textfield.text = keyforIP as? String
        SendToTEL_textfield.text = keyforTEL as? String

    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if textField.tag == 1 && textField.text != ""{
            //NSUserDefaultsのインスタンスを生成
            let defaults = NSUserDefaults.standardUserDefaults()
            
            //"IP"というキーで配列namesを保存
            defaults.setObject(textField.text, forKey:"IP")
            
            // シンクロを入れないとうまく動作しないときがあります
            defaults.synchronize()
        }
        else if textField.tag == 2 && textField.text != ""{
            //NSUserDefaultsのインスタンスを生成
            let defaults = NSUserDefaults.standardUserDefaults()
            
            //"TEL"というキーで配列namesを保存
            defaults.setObject(textField.text, forKey:"TEL")
            
            // シンクロを入れないとうまく動作しないときがあります
            defaults.synchronize()
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        //if textField.tag == 1{
            textField.resignFirstResponder()
//        }else if textField.tag == 2{
           // textField.resignFirstResponder()
//        }
        return true
    }
    
}
