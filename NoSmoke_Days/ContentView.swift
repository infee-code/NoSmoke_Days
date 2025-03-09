//
//  ContentView.swift
//  NoSmoke_Days
//
//  Created by 万迎飞 on 2025/3/9.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var quitData = QuitSmokingData()
    @State private var hasSetQuitDate = false
    
    var body: some View {
        Group {
            if hasSetQuitDate {
                NavigationStack {
                    MainView(quitData: quitData)
                }
            } else {
                SetupView(quitData: quitData, isSetupComplete: $hasSetQuitDate)
            }
        }
        .onAppear {
            // 检查是否已经设置了戒烟日期
            if let savedDate = quitData.loadQuitDate() {
                quitData.quitDate = savedDate
                hasSetQuitDate = true
            }
        }
    }
}

#Preview {
    ContentView()
}
