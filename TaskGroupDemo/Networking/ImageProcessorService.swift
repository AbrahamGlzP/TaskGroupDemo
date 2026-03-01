//
//  ImageProcessorService.swift
//  TaskGroupDemo
//
//  Created by Abraham Gonzalez Puga on 26/02/26.
//

import SwiftUI

struct ProcessedImage: Identifiable {
    let id: Int
    let name: String
    let color: Color // Simulate the image with a color
    let proccssing: Double
}

class ImageProcessorService {
    
    // Simulates download and process an image
    func processImage(id: Int) async throws -> ProcessedImage {
        let time = Double.random(in: 0.5...3.0)
        try await Task.sleep(for: .seconds(time))
        
        let colors: [Color] = [.red, .green, .blue, .yellow, .purple, .pink, .orange]
        
        return ProcessedImage(id: id,
                              name: "Image \(id)",
                              color: colors[id % colors.count],
                              proccssing: time)
    }
    
    // MARK: Sequential download
    func processSequential(count: Int) async throws -> [ProcessedImage] {
        var results: [ProcessedImage] = []
        for id in 1...count {
            let image = try await processImage(id: id)
            results.append(image)
        }
        return results
    }
    
    // MARK: ✅ Task group - everything in parallel
    func processParallel(count: Int) async throws -> [ProcessedImage] {
        try await withThrowingTaskGroup(of: ProcessedImage.self) { group in
            for id in 1...count {
                group.addTask { try await self.processImage(id: id) }
            }
            
            var results: [ProcessedImage] = []
            for try await image in group {
                results.append(image)
            }
            return results.sorted(by: { $0.id < $1.id })
        }
    }
    
    // MARK: ✅ Task group with limited concurrency
    func processLimited(count: Int, maxConcurrent: Int) async throws -> [ProcessedImage] {
        try await withThrowingTaskGroup(of: ProcessedImage.self) { group in
            let ids = Array(1...count)
            var iterator = ids.makeIterator()
            var inFlight = 0
            
            // Start with the first maxConcurrent
            while inFlight < maxConcurrent, let id = iterator.next() {
                group.addTask { try await self.processImage(id: id) }
                inFlight += 1
            }
            
            var results: [ProcessedImage] = []
            for try await image in group {
                results.append(image)
                
                // For every result, we add the next one if exists
                if let id = iterator.next() {
                    group.addTask {
                        try await self.processImage(id: id)
                    }
                }
            }
            return results.sorted(by: { $0.id < $1.id })
        }
    }
    
}
