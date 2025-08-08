//
//  RegisterFormValidator.swift
//  Findation
//
//  Created by Yoy0z-maps on 8/7/25.
//

import Foundation

func isRegisterFormValid(email: String, password: String, nickname: String) -> Bool {
    return isValidEmail(email) && !password.isEmpty && !nickname.isEmpty
}

private func isValidEmail(_ email: String) -> Bool {
    let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
    return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
}
