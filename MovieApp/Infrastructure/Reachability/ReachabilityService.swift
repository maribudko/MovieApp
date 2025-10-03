//
//  ReachabilityService.swift
//  MovieApp
//
//  Created by Mari Budko on 03.10.2025.
//

import Foundation
import Network

final class ReachabilityService: ReachabilityServiceProtocol {
    private let monitor = NWPathMonitor()
    private var currentStatus: Bool = true
    private let queue = DispatchQueue(label: "ReachabilityService")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.currentStatus = (path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }

    var isOnline: Bool { currentStatus }
}
