//
//  Category.swift
//  ToDo
//
//  Created by Лилия Феодотова on 21.03.2023.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var color: String?
    let items = List<Item>()
}
