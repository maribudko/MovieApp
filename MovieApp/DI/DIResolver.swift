//
//  DIResolver.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

public protocol DIResolver {
    func resolve<T>(_ type: T.Type) -> T
    func resolve<T, Arg>(_ type: T.Type, argument: Arg) -> T
    func resolve<T, Arg1, Arg2>(_ type: T.Type, arguments arg1: Arg1, _ arg2: Arg2) -> T
}
