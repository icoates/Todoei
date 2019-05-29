//
//  Category.swift
//  Todoei
//
//  Created by Ian Coates on 5/28/19.
//  Copyright © 2019 Ian Coates. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name : String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
    
}
