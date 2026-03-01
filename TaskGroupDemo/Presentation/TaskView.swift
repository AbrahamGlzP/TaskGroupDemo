//
//  TaskView.swift
//  TaskGroupDemo
//
//  Created by Abraham Gonzalez Puga on 26/02/26.
//

import SwiftUI

struct TaskView: View {
    
    @State private var viewModel = TaskViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Timer
                if viewModel.isLoading {
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("Loading...")
                            .foregroundStyle(.secondary)
                    }
                } else if viewModel.elapsedTime > 0 {
                    Text(String(format: "%.1fs", viewModel.elapsedTime))
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundStyle(viewModel.elapsedTime < 4 ? .green : .red)
                }
                
                VStack(spacing: 8) {
                    Button("❌ Sequential") {
                        Task { await viewModel.runSequential() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .disabled(viewModel.isLoading)
                    
                    Button("✅ Task group - everything in parallel") {
                        Task { await viewModel.runParallel() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(viewModel.isLoading)
                    
                    Button("⚡️ Task group - Maximum 3 concurrent tasks") {
                        Task { await viewModel.runLimitedConcurrent() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal)
                
                // Gird de imagenes
                
                if !viewModel.images.isEmpty {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4)) {
                        ForEach(viewModel.images) { image in
                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(image.color)
                                    .frame(height: 60)
                                Text(image.name)
                                    .font(.caption2)
                                Text(String(format: "%.1fs", image.proccssing))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                GroupBox("Event log") {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 6) {
                            ForEach(viewModel.log, id: \.self) { entry in
                                Text(entry)
                                    .font(.system(.caption, design: .monospaced))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                    }
                    .frame(maxHeight: 120)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("TaskGroup")
        }
    }
}
