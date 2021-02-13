//
//  MemoList.swift
//  Schedule_B
//
//  Created by admin on 2021/02/12.
//

import Foundation

class MemoList{
  
  var mianText : String
  var subText : Date
  
  init(mainText : String) {
    self.mianText = mainText
    subText = Date()
    
  }
  
  static var dummyList = [
    MemoList(mainText: "나른나른"),
    MemoList(mainText: "버블"),
    MemoList(mainText: "키난"),
    MemoList(mainText: "바트")
  ]
}
