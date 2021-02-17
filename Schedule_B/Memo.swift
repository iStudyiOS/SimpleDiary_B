//
//  MemoList.swift
//  Schedule_B
//
//  Created by admin on 2021/02/12.
//

import Foundation

class Memo{
  
  var mainText: String
  var subText: Date
  var contentText: String
  
  init(mainText : String, contentText: String) {
    self.mainText = mainText
    self.contentText = contentText

    subText = Date()
    
  }
}
