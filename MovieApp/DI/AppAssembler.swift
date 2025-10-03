//
//  AppAssembler.swift
//  MovieApp
//
//  Created by Mari Budko on 02.10.2025.
//

import Swinject

public final class AppAssembler {
    public static let shared = AppAssembler()
    
    private let assembler: Assembler
    public let resolver: DIResolver
    
    private init() {
        assembler = Assembler([
            NetworkAssembly(),
            RepositoryAssembly(),
            ReachabilityAssembly(),
            MoviesListAssembly()
        ])
        resolver = SwinjectResolver(resolver: assembler.resolver)
    }
    
    public func addAssembly(assembly: Assembly) {
        assembler.apply(assembly: assembly)
    }
    
    public func addAssemblies(assemblies: [Assembly]) {
        assembler.apply(assemblies: assemblies)
    }
}
