//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

//OpenEarsに音声合成（TTS）を制御するクラス。
#import <Slt/Slt.h>
#import <OpenEars/OEFliteController.h>
//語彙生成するクラスOEPocketsphinxController(OpenEarsでローカル音声認識を制御するクラス。)を理解することができます。
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>
//OpenEarsでローカル音声認識を制御するクラス。
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>
/*OEEventsObserverは、あなたはどこでもあなたのアプリ内からOpenEarsのイベントについての
 情報を受信できるようにするデリゲートメソッドの大規模なセットを提供します。
 必要な数のOEEventsObserversを作成し、それらを同時に使用して情報を受け取ることができます。*/
#import <OpenEars/OEEventsObserver.h>

#import <OpenEars/OELogging.h>
