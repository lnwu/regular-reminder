// 最小化启动测试 - 用于诊断启动性能问题
// 使用方法：在 scheme 中将此文件设为主入口

import SwiftUI

@main
struct TestLaunchApp: App {
    // 完全不加载任何数据，测试纯 UI 启动速度
    var body: some Scene {
        WindowGroup {
            TestLaunchView()
        }
    }
}

struct TestLaunchView: View {
    @State private var launchTime = Date()
    @State private var renderTime: TimeInterval = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("启动测试")
                .font(.largeTitle)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("渲染时间: \(renderTime, format: .number.precision(.fractionLength(3)))s")
                    .font(.title2)
                
                if renderTime > 1.0 {
                    Text("⚠️ 启动较慢")
                        .foregroundStyle(.orange)
                } else if renderTime > 3.0 {
                    Text("🐌 启动很慢")
                        .foregroundStyle(.red)
                } else {
                    Text("✅ 启动正常")
                        .foregroundStyle(.green)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(.rect(cornerRadius: 10))
            
            Text("如果使用此测试启动很快，\n问题在 RegularReminderApp.swift 的初始化代码")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .onAppear {
            renderTime = Date().timeIntervalSince(launchTime)
        }
    }
}
