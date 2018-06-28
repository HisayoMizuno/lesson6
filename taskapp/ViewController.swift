//
//  ViewController.swift
//  taskapp
//
//  Created by ミップ on 2018/06/12.
//  Copyright © 2018年 株式会社ミップ. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
   
    @IBOutlet weak var tableView: UITableView! //OutletTableView
    let realm = try!Realm() //Realmのインタンス化
    var taskArray = try!Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        
      /*==================================*/
        searchBar.delegate = self
        searchBar.placeholder = "検索"
        searchBar.setValue("キャンセル", forKey: "_cancelButtonText")
      /*==================================*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*==================================*/
    // キャンセルボタンが押された時に呼ばれる
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            taskArray = try! Realm().objects(Task.self)
        }
        else{
            taskArray = try! Realm().objects(Task.self).filter("category == %@", searchText)
        }
        tableView.reloadData()
    }
    
    /*==================================*/

    //--- セルの数を返す（メソッド）------------- -
    func tableView(_ tableView: UITableView , numberOfRowsInSection section:Int) -> Int{
        //taskArrayの数を返す
        return taskArray.count
    }
    //--- 各セル内容を返す（メソッド）---------------------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //再生可能なセルを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //cellの値を設定
        //タイトル
        let task = taskArray[indexPath.row] //title部分1
        cell.textLabel?.text = task.title
        
        
        //日付
        let formatter = DateFormatter() //任意の日付フォーマットに変更
        formatter.dateFormat = "yyyy-MM-dd HH:MM"
        
        let dataString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dataString + "  (" + task.category + ")"
        return cell
    }
    //--- セルタップ時に呼ばれる（メソッド）--------------
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //タスク入力画面に遷移させる
        performSegue(withIdentifier: "cellSegue", sender: nil)
        
    }
    // ---セルが削除が可能か並び替え可能かを伝える（メソッド）-------------
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    //--- セルが削除されるときに呼ばれる（メソッド）--------------
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        //ローカル通知をキャンセルし、DBからタスクを削除
        if editingStyle == .delete {
            //削除タスクを取得
            let task = self.taskArray[indexPath.row]
            //通知キャンセル
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            //DBからtaskを削除
            try! realm.write {
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            //ローカル通知一覧（未通知）

            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/-----")
                    print(request)
                    print("-----/")
                }
            }
        }
    }
    //segueで画面遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
  
        if segue.identifier == "cellSegue" { //セルがタップされた
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }
        else { //+が押された
            let task = Task() //インスタンス生成
            task.date = Date()
            //DB
            let allTasks = realm.objects(Task.self)
            
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    //入力画面から戻ってきた時にtableViewを更新
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    
    
}

