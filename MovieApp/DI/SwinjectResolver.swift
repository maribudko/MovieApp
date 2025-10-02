//
//  DIContainer.swift
//  MovieApp
//
//  Created by Mari Budko on 30.09.2025.
//

import Swinject

final class SwinjectResolver: DIResolver {
    
    private let resolver: Resolver
    
    init(resolver: Resolver) {
        self.resolver = resolver
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        guard let resolved = resolver.resolve(type) else {
            fatalError("Could not resolve type \(type)")
        }
        return resolved
    }
    
    func resolve<T, Arg>(_ type: T.Type, argument: Arg) -> T {
        guard let resolved = resolver.resolve(type, argument: argument) else {
            fatalError("Could not resolve type \(type) with argument \(Arg.self)")
        }
        return resolved
    }
    
    func resolve<T, Arg1, Arg2>(_ type: T.Type, arguments arg1: Arg1, _ arg2: Arg2) -> T {
        guard let resolved = resolver.resolve(type, arguments: arg1, arg2) else {
            fatalError("Could not resolve type \(type) with argument \(Arg1.self) and \(Arg2.self)")
        }
        return resolved
    }
    
    
}

