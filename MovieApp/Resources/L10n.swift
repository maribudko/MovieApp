//
//  L10n.swift
//  MovieApp
//
//  Created by Mari Budko on 30.09.2025.
//

import Foundation

enum L10n {
    enum Error {
        static var offline: String {
            NSLocalizedString("error.network.offline",
                              tableName: "Localizable",
                              bundle: .main,
                              comment: "No internet connection")
        }
        static func http(_ code: Int) -> String {
            let format = NSLocalizedString("error.network.http",
                                           tableName: "Localizable",
                                           bundle: .main,
                                           comment: "HTTP error with code")
            return String(format: format, code)
        }
        static var decoding: String {
            NSLocalizedString("error.data.decoding",
                              tableName: "Localizable",
                              bundle: .main,
                              comment: "Decoding error")
        }
        static var unknown: String {
            NSLocalizedString("error.unknown",
                              tableName: "Localizable",
                              bundle: .main,
                              comment: "Unknown error")
        }
    }
}
