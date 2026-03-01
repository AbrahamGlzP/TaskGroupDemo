//
//  TaskViewModel.swift
//  TaskGroupDemo
//
//  Created by Abraham Gonzalez Puga on 26/02/26.
//

import SwiftUI

@Observable
@MainActor
class TaskViewModel {
    var images: [ProcessedImage] = []
    var isLoading = false
    var elapsedTime: Double = .zero
    var progress: Int = .zero
    var log: [String] = []
    
    private let service = ImageProcessorService()
    private let imageCount = 8
    
    func runSequential() async {
        await run(label: "Sequential") {
            try await self.service.processSequential(count: self.imageCount)
        }
    }
    
    func runParallel() async {
        await run(label: "Parallel") {
            try await self.service.processParallel(count: self.imageCount)
        }
    }
    
    func runLimitedConcurrent() async {
        await run(label: "Limited to 3 task at a time") {
            try await self.service.processLimited(count: self.imageCount, maxConcurrent: 3)
        }
    }
    
    func run(label: String, fetch: () async throws -> [ProcessedImage]) async {
        isLoading = true
        images = []
        progress = 0
        log = []
        
        log.insert("🚀 Initiating: \(label)", at: .zero)
        log.insert("📦 Processing", at: .zero)
        
        let start = Date()
        
        do {
            images = try await fetch()
            elapsedTime = Date().timeIntervalSince(start)
            log.insert("✅ Completed in \(String(format: "%.1f", elapsedTime))", at: .zero)
        } catch {
            log.insert("❌ Error: \(error.localizedDescription)", at: .zero)
        }
        
        isLoading = false
    }
}
