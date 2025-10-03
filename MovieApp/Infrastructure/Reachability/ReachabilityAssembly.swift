//
//  ReachabilityAssembly.swift
//  MovieApp
//
//  Created by Mari Budko on 03.10.2025.
//

import Foundation
import Swinject

final class ReachabilityAssembly: Assembly {
    func assemble(container: Container) {
        container.register(ReachabilityServiceProtocol.self) { _ in
            ReachabilityService()
        }
        .inObjectScope(.container)
    }
}
