//
//  Task.swift
//  taskapp
//
//  Created by ミップ on 2018/06/12.
//  Copyright © 2018年 株式会社ミップ. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var contents = ""
    @objc dynamic var date = Date()
    @objc dynamic var category = ""
    //プライマリーキー設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
}
