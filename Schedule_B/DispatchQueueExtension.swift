//
//  DispatchQueueExtension.swift
//  Schedule_B
//
//  Created by Shin on 2/24/21.
//

import Foundation

extension DispatchQueue {
    static func runOnlyMainThread(_ closure: @escaping () -> Void ) {
        if Thread.isMainThread {
            closure()
        }else {
            DispatchQueue.main.async {
                closure()
            }
        }
    }
}
