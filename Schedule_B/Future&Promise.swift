//
//  Future.swift
//  Schedule_B
//
//  Created by Shin on 2/20/21.
//

import Foundation

class Future<Value> {
    typealias Result = Swift.Result<Value, Error>
    
    fileprivate var result: Result? {
        didSet { result.map(report) }
    }
    private var callbacks = [(Result) -> Void]()
    
    func observe(using callback: @escaping (Result) -> Void) {
        if let result = result {
            return callback(result)
        }
        callbacks.append(callback)
    }
    private func report(result: Result) {
        callbacks.forEach { $0(result) }
        callbacks = []
    }
    
    func chained<T>(using closure: @escaping (Value) throws -> Future<T>) -> Future<T> {
        let promise = Promise<T>()
        
        observe { result in
            switch result {
            case .success(let value):
                do {
                    let future = try closure(value)
                    
                    future.observe { result in
                        switch result{
                        case .success(let value):
                            promise.resolve(with: value)
                        case .failure(let error):
                            promise.reject(with: error)
                        }
                    }
                }catch {
                    promise.reject(with: error)
                }
            case .failure(let error):
                promise.reject(with: error)
            }
        }
        return promise
    }
    func transFormed<T> (with closure: @escaping (Value) throws -> T) -> Future<T> {
        chained { value in
            try Promise(value: closure(value))
        }
    }
}


class Promise<Value>: Future<Value> {
    init(value: Value? = nil) {
        super.init()
        result = value.map(Result.success)
    }
    func resolve(with value: Value) {
        result = .success(value)
    }
    func reject(with error: Error) {
        result = .failure(error)
    }
}
