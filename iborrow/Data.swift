//
//  Data.swift
//  iborrow
//
//  Created by sudo on 4/1/19.
//  Copyright © 2019 sudo. All rights reserved.
//

import Foundation
import RealmSwift
// Realm properties declared
class Data: Object {
  @objc dynamic var topText:String = ""
  @objc dynamic var bottomText:String = ""
  @objc dynamic var image:NSData?
}
