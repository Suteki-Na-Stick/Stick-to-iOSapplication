//
//  ViewController.swift
//  Stickapp
//
//  Created by 早坂彪流 on 2016/04/10.
//  Copyright © 2016年 takeru haysaka. All rights reserved.
//

import UIKit
import Charts
import Starscream
class StatusV_ViewController: UIViewController,WebSocketDelegate {

    
    var socket:WebSocket!
    
    @IBOutlet weak var ave_label: UILabel!
    
    @IBOutlet weak var stdlabel: UILabel!
    
    @IBOutlet weak var select_io_label: UILabel!
    
    @IBOutlet weak var light_button: UIButton!
    
    @IBOutlet weak var reft_button: UIButton!
    
    @IBOutlet weak var BarChart_foundtionView: LineChartView!
    var Selecters_Index:Int = 0//"温度:0","湿度:1","体感温度:2""
    var SendSelecters_Index:Int = 0//サーバーに送りつけたものもIndex
    var firstloadView:Bool = false//初期設定のためのflag
    let Selecters_name: [String] = ["温度","湿度","体感温度","気圧"]
    var stringsdate:[String]!=[]
    let MAXSIZESEE = 6//見るもの
    var Temp:[Double]!=[]
    var Hum:[Double]!=[]
    var Temp_H:[Double]!=[]
    var hPs:[Double]!=[]
    //var LineTimer:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        light_button.addTarget(self, action: #selector(StatusV_ViewController.light_button_Event(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        reft_button.addTarget(self, action: #selector(StatusV_ViewController.reft_button_Event(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // 「ud」というインスタンスをつくる。
        let ud = NSUserDefaults.standardUserDefaults()
        
        // キーがidの値をとります。
        var udId : AnyObject! = ud.objectForKey("IP")
        
        if udId == nil{
            udId = ""
        }

        socket = singlesocket().websocketshared(udId as! String)
        //WebSocket(url: NSURL(string: "ws://\(URLs):81/")!)
        socket.delegate = self
        socket.connect()
        
        let timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(StatusV_ViewController.Allupdate(_:)), userInfo: nil, repeats: true)
        
        // run loopに登録する
        // run loopに登録することでタイマー処理が開始される
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
        
        let timerfirst = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(StatusV_ViewController.AllFupdate(_:)), userInfo: nil, repeats: true)
        
        // run loopに登録する
        // run loopに登録することでタイマー処理が開始される
        NSRunLoop.currentRunLoop().addTimer(timerfirst, forMode: NSDefaultRunLoopMode)
        
        //timerfirst.invalidate()
        select_io_label.text = Selecters_name[Selecters_Index]
        ave_label.text = ""
        stdlabel.text = ""
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setChart(dataPoints: [String], values: [Double]) {
        BarChart_foundtionView.noDataText = "You need to provide data for the chart."
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(yVals: dataEntries, label: Selecters_name[Selecters_Index])
        let chartData = LineChartData(xVals: stringsdate, dataSet: chartDataSet)
        BarChart_foundtionView.data = chartData
    }
    
    func websocketDidConnect(socket: WebSocket) {
        print("websocket is connected")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        print("Received text: \(text)")
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)
        do{
        let Dic:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            
            if SendSelecters_Index == 0{
                //MAXSIZESEEまで詰まっていたら先頭から削る
                if Temp.count == MAXSIZESEE{
                    Temp.removeAtIndex(0)
                    Hum.removeAtIndex(0)
                    Temp_H.removeAtIndex(0)
                    hPs.removeAtIndex(0)
                    stringsdate.removeAtIndex(0)
                }
                self.Temp.append(Double(Dic["Temp"] as! String)!)
                self.Hum.append(Double(Dic["Hum"] as! String)!)
                self.Temp_H.append(Double(Dic["Temp_H"] as! String)!)
                self.hPs.append(Double(Dic["hPa"] as! String)!)
                
                let now = NSDate()
                let formatter = NSDateFormatter()
                formatter.dateFormat = "mm:ss"
                stringsdate.append(formatter.stringFromDate(now))
                if Dic["weather"] as! String == "stable"{
                    stdlabel.text = "現在の天気予報：安定した天気⛅️"
                }else if Dic["weather"] as! String == "sunny"{
                    stdlabel.text = "現在の天気予報：晴天☀️"
                }else if Dic["weather"] as! String == "cloudy"{
                    stdlabel.text = "現在の天気予報：曇り☁️"
                }else if Dic["weather"] as! String == "unstable"{
                    stdlabel.text = "現在の天気予報：不安定な天気☁️"
                }else if Dic["weather"] as! String == "thunderstorm"{
                    stdlabel.text = "現在の天気予報：雷雨⚡️"
                }else if Dic["weather"] as! String == "unknown"{
                    stdlabel.text = "現在の天気予報：（データが足りなくてまたは測定不能）不明"
                }
                //初回だけreload
//                if 0<Temp.count && firstloadView==false{
//                    BarChart_foundtionView.animate(xAxisDuration: 2.0)
//                    BarChart_foundtionView.pinchZoomEnabled = false
//                    //        BarChart_foundtionView.drawBordersEnabled = true
//                    //BarChart_foundtionView.descriptionText = "全体のデータ"
//                    select_io_label.text = Selecters_name[Selecters_Index]
//                    firstloadView = true
//                    setChart(stringsdate, values: Temp)
//                    ave_label.text = "現在の気温:\(Temp[Temp.count-1])*C"
//                }
                BarChart_foundtionView.animate(xAxisDuration: 2.0)
                BarChart_foundtionView.pinchZoomEnabled = false
                select_io_label.text = Selecters_name[Selecters_Index]
                if Selecters_Index == 0{
                    ave_label.text = "現在の気温:\(Temp[Temp.count-1])*C"
                    setChart(stringsdate, values: Temp)
                }else if Selecters_Index == 1{
                    ave_label.text = "現在の湿度:\(Hum[Hum.count-1]) %"
                    setChart(stringsdate, values: Hum)
                }else if Selecters_Index == 2{
                    ave_label.text = "現在の体感温度:\(Temp_H[Temp_H.count-1])*C"
                    setChart(stringsdate, values: Temp_H)
                }else if Selecters_Index == 3{
                    ave_label.text = "現在の気圧:\(hPs[Temp_H.count-1]) hPs"
                    setChart(stringsdate, values: hPs)
                }

            }
        }catch{
        
        }
        
        
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: NSData) {
        print("Received data: \(data.length)")
        
    }

    
    func light_button_Event(sender:UIButton!){
        if Temp.isEmpty {
            return
        }
        if Selecters_Index<Selecters_name.count-1{
            Selecters_Index += 1
        }else{
            Selecters_Index=0
        }
        BarChart_foundtionView.animate(xAxisDuration: 2.0)
        BarChart_foundtionView.pinchZoomEnabled = false
        select_io_label.text = Selecters_name[Selecters_Index]
        if Selecters_Index == 0{
            ave_label.text = "現在の気温:\(Temp[Temp.count-1])*C"
            setChart(stringsdate, values: Temp)
        }else if Selecters_Index == 1{
            ave_label.text = "現在の湿度:\(Hum[Hum.count-1]) %"
            setChart(stringsdate, values: Hum)
        }else if Selecters_Index == 2{
            ave_label.text = "現在の体感温度:\(Temp_H[Temp_H.count-1])*C"
            setChart(stringsdate, values: Temp_H)
        }else if Selecters_Index == 3{
            ave_label.text = "現在の体感温度:\(hPs[Temp_H.count-1]) hPs"
            setChart(stringsdate, values: hPs)
        }
        
    }
    func reft_button_Event(sender:UIButton!){
        if Temp.isEmpty {
            return
        }
        if 0<Selecters_Index{
            Selecters_Index -= 1
        }else{
            Selecters_Index=Selecters_name.count-1
        }
        BarChart_foundtionView.animate(xAxisDuration: 2.0)
        BarChart_foundtionView.pinchZoomEnabled = false
        select_io_label.text = Selecters_name[Selecters_Index]
        if Selecters_Index == 0{
            ave_label.text = "現在の気温:\(Temp[Temp.count-1])*C"
            setChart(stringsdate, values: Temp)
        }else if Selecters_Index == 1{
             ave_label.text = "現在の湿度:\(Hum[Hum.count-1]) %"
            setChart(stringsdate, values: Hum)
        }else if Selecters_Index == 2{
            ave_label.text = "現在の体感温度:\(Temp_H[Temp_H.count-1])*C"
            setChart(stringsdate, values: Temp_H)
        }else if Selecters_Index == 3{
            ave_label.text = "現在の体感温度:\(hPs[Temp_H.count-1]) hPs"
            setChart(stringsdate, values: hPs)
        }
    }
    func Allupdate(sender:NSTimer!){
        SendSelecters_Index=0
        socket.writeString("ALLUPDATE")
    }
    func AllFupdate(sender:NSTimer!){
        SendSelecters_Index=0
        socket.writeString("ALLUPDATE")
        sender.invalidate()
    }
    
}
public class singlesocket {
    
    static var sharedsocket:singlesocket{
        return singlesocket()
    }
    func websocketshared (URLs:String)-> WebSocket {
        //"192.168.43.26"
        return WebSocket(url: NSURL(string: "ws://\(URLs):81/")!)
    }
    private init(){
    }
}
