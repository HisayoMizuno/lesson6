//
//  InputViewController.swift
//  taskapp
//
//  Created by ミップ on 2018/06/12.
//  Copyright © 2018年 株式会社ミップ. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications


class InputViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField! // text入力
    @IBOutlet weak var contentsTextView: UITextView! //テキストエリア
    @IBOutlet weak var datePicker: UIDatePicker!  //datePicker
    @IBOutlet weak var category: UITextField! //カテゴリ
    
    var task: Task! //遷移時の変数を宣言
    let realm = try! Realm() //realmインタンス化
    //当画面が非表示になるときに呼ばれるメソッド
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write { //writeメソッド
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.category.text!
            self.realm.add(self.task, update: true)
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //背景タップ　→ キーボードを閉じる
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self , action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture) //ジェスチャーを登録
        //入力部分に当該セルデータを表示する
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        category.text = task.category
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @objc func dismissKeyboard(){
        //キーボードを閉じる
        view.endEditing(true)
    }
    //タスクのローカル通知を登録する
    func setNortification(task:Task){
        let content = UNMutableNotificationContent()
        //タイトル設定（ない場合はメッセージ無し＆音通知のみ）
        if task.title == "" {
            content.title = "(タイトルなし)"
        }
        else{
            content.title = task.title
        }
        //テキストを設定（ない場合はメッセージ無し＆音通知のみ）
        if task.contents != "" {
            content.body = "(内容なし)"
        }
        else{
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default()
        
        //ローカル通知のトリガーを生成（日付）
        let calender = Calendar.current
        let dateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        //ローカル通知作成（identifier ,content ,triggerから）ーー＞identifierが同じだと上書き
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        //ローカル通知を登録
        let center  = UNUserNotificationCenter.current()
        center.add(request){
            (error) in
            print(error ?? "ローカル通知OK")
        }
        //ローカル通知一覧をログ出力
        center.getPendingNotificationRequests {
            (requests: [UNNotificationRequest]) in
            for request in requests {
                print("---")
                print(request)
                print("---")
            }
        }
        

    }

}
