//
//  Validator.swift
//
//  Created by Evan Xie on 2019/3/29.
//

import Foundation

/**
 A generic value validator. `closure` is reponsible for validation logic.
 For more information, see [Using errors as control flow in Swift].
 
 [Using errors as control flow in Swift]:
 https://www.swiftbysundell.com/posts/using-errors-as-control-flow-in-swift
 
 Create validator example:
 ```
 let passwordValidator: Validator<String> = Validator { string in
    try validate(
        string.count >= 7,
        errorMessage: "Password must contain min 7 characters"
    )

    try validate(
        string.lowercased() != string,
        errorMessage: "Password must contain an uppercased character"
    )

    try validate(
        string.uppercased() != string,
        errorMessage: "Password must contain a lowercased character"
    )
 }
 ```
 
 Start validating example:
 ```
 do {
    try validate("user", using: passwordValidator)
 } catch {
    print(error.localizedDescription)
 }
 ```
 */
public struct Validator<Value> {
    internal var closure: (Value) throws -> Void
    
    public init(closure: @escaping (Value) throws -> Void) {
        self.closure = closure
    }
}

/**
 A localized error when validation fails, can be showed to the user directly.
 */
public struct ValidationError: LocalizedError {
    private var message: String
    
    public var errorDescription: String? {
        return message
    }
    
    internal init(message: String) {
        self.message = message
    }
}

/**
 Perform validation, if fails, throw `ValidationError`.
 
 - Parameters:
    - condition: Your validation logic.
    - messageExpression: The localized error message you provided for validation failure.
 
 - Throws: `ValidationError`
 */
public func validate(_ condition: @autoclosure () -> Bool,
              errorMessage messageExpression: @autoclosure () -> String) throws {
    
    guard condition() else {
        let message = messageExpression()
        throw ValidationError(message: message)
    }
}

/**
 Validate `value` using validator you provided.
 
 - Throws: Throw the error from the validator you provided.
 */
public func validate<T>(_ value: T, using validator: Validator<T>) throws {
    try validator.closure(value)
}
