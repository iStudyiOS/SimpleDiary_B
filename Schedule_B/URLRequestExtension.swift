//
//  Promise.swift
//  Schedule_B
//
//  Created by Shin on 2/20/21.
//

import Foundation

extension URLRequest {
    func sendWithPromise(_ givenPromise: Promise<Data>? = nil) -> Future<Data> {
        let promise = givenPromise == nil ? Promise<Data>(): givenPromise!
        
        let task = URLSession.shared.dataTask(with: self) {
            data, response, error in
            print("Reponse of data task")
            print(response!)
            if let error = error {
                promise.reject(with: error)
            }else {
                promise.resolve(with: data ?? Data())
            }
        }
        task.resume()
        
        return promise
    }
}

