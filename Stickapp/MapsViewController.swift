//
//  MapsViewController.swift
//  Stickapp
//
//  Created by 早坂彪流 on 2016/04/10.
//  Copyright © 2016年 takeru haysaka. All rights reserved.
//

import MapKit
import CoreLocation
import MessageUI
class MapsViewController: UIViewController, MKMapViewDelegate,CLLocationManagerDelegate,MFMessageComposeViewControllerDelegate {
    
    private var locationManager:CLLocationManager!
    private var alreadyStartingCoordinateSet:Bool!=false
    private var currentLocationSave:CLLocationCoordinate2D!
    @IBOutlet var mapView:MKMapView!
    @IBOutlet weak var sendmypoint_button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        sendmypoint_button.addTarget(self, action: #selector(MapsViewController.sendmypoint_buttonEvent(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.mapView.delegate = self
        /*
         location設定
         */
        //ユーザーによる位置情報サービスの許可状態をチェック
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Denied||CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Restricted  {
            //ユーザーはこのアプリによる位置情報サービスの利用を許可していない、または「設定」で無効にしている
            print("Location services is unauthorized.")
        }else{
            ///位置情報サービスを利用できる、またはまだ利用許可要求を行っていない
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            
            //利用許可要求をまだ行っていない状態であれば要求
            if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined{
                //許可の要求
                //アプリがフォアグラウンドにある間のみ位置情報サービスを使用する許可を要求
               // self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.requestAlwaysAuthorization()
            }
            
             //精度要求
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            //最小移動間隔
            //self.locationManager.distanceFilter = 100.0 //100m 移動ごとに通知
            self.locationManager.distanceFilter = kCLDistanceFilterNone; //全ての動きを通知（デフォルト）
             //測位開始
            self.locationManager.startUpdatingLocation()
            //mapの種類
            self.mapView.mapType = MKMapType.Hybrid
        }
        
        // 縮尺を設定
        var region:MKCoordinateRegion = mapView.region
        //region.center = location
        region.span.latitudeDelta = 0.02
        region.span.longitudeDelta = 0.02
        
        mapView.setRegion(region,animated:true)
        
        // 表示タイプを航空写真と地図のハイブリッドに設定
        //        mapView.mapType = MKMapType.Standard
        //        mapView.mapType = MKMapType.Satellite
        mapView.mapType = MKMapType.Hybrid
        //ユーザの回転を許可しない
        self.mapView.rotateEnabled = false
        mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)
         mapView.userTrackingMode = MKUserTrackingMode.FollowWithHeading
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    MARK::CLLocationManagerDelegate
     */
    //位置情報更新時に呼ばれる
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //ユーザの位置を表示するかどうか
        self.mapView.showsUserLocation = true
        //最新の位置情報を取得し、そこからマップの中心座標を決定

        let currentLocation = locations.last
        let centerCoordinate = currentLocation?.coordinate
        currentLocationSave = centerCoordinate
        //縮尺度を指定
       // let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)//数が小さいほど拡大率アップ
        
        //設定した縮尺で現在地を中心としたマップをセット（初回1回のみ）
        if (alreadyStartingCoordinateSet == false) {
            //let newRegion = MKCoordinateRegionMake(centerCoordinate!, coordinateSpan)
            //self.mapView.setRegion(newRegion, animated: true)
            alreadyStartingCoordinateSet = true
           
        }
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("didFailWithError")
    }
    // 認証が変更された時に呼び出されるメソッド.
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status{
        case .AuthorizedWhenInUse:
            print("AuthorizedWhenInUse")
        case .Authorized:
            print("Authorized")
        case .Denied:
            print("Denied")
        case .Restricted:
            print("Restricted")
        case .NotDetermined:
            print("NotDetermined")
             if locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)) { locationManager.requestWhenInUseAuthorization() }
        }
    }
    
    /*MKMapViewDelegate*/
    // Regionが変更された時に呼び出されるメソッド.
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("regionDidChangeAnimated")
    }
    
    func alertLocationServicesDisabled() {
        let title = "Location Services Disabled"
        let message = "You must enable Location Services to track your run."
        
        if (NSClassFromString("UIAlertController") != nil) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { action in
                let url = NSURL(string: UIApplicationOpenSettingsURLString)
                UIApplication.sharedApplication().openURL(url!)
            }))
            alert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            //UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Close").show()
        }
    }
    
    /*MFMessageComposeViewControllerDelegate*/
    
    func SendSMS()->Bool
    {
        // 送信可能かどうかのチェック
        if MFMessageComposeViewController.canSendText()
        {
            let nowlatitude = currentLocationSave.latitude
            let nowlongitude = currentLocationSave.longitude
            let mFMessageComposeViewController = MFMessageComposeViewController()
            // 「ud」というインスタンスをつくる。
            let ud = NSUserDefaults.standardUserDefaults()
            
            // キーがidの値をとります。
            var udId : AnyObject! = ud.objectForKey("TEL")
            
            if udId == nil{
                udId = ""
            }

            mFMessageComposeViewController.recipients = [udId as! String]
            mFMessageComposeViewController.body = "Helpme！。私は今ここにいます\n緯度:\(nowlatitude)経度:\(nowlongitude)\n"  // 本文
            mFMessageComposeViewController.messageComposeDelegate = self
            self.presentViewController(mFMessageComposeViewController, animated: true, completion: nil) // 画面表示
            return true
        }else{
            return false
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult)
    {
        
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue:   // キャンセルした
            print("cancelled.")
        case MessageComposeResultSent.rawValue:        // 送信した
            print("sent")
        case MessageComposeResultFailed.rawValue:      // 失敗した
            print("failed.")
        default:
            print("unknown.")
        }
        
        // 処理完了後、画面を消去する
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func sendmypoint_buttonEvent(sender:UIButton!){
        SendSMS()
    }
}

