import SwiftUI

struct MainView: View {
    @ObservedObject var quitData: QuitSmokingData
    @State private var showingResetAlert = false
    @State private var showingSetupView = false
    @State private var selectedNewDate = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                headerView
                
                progressView
                
                checkInView
                
                statisticsView
            }
            .padding()
        }
        .navigationTitle("清息")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    generateHapticFeedback(style: .medium)
                    showingResetAlert = true
                }) {
                    Image(systemName: "arrow.counterclockwise.circle")
                        .foregroundColor(.red)
                }
            }
        }
        .alert("重新开始", isPresented: $showingResetAlert) {
            Button("取消", role: .cancel) {
                generateHapticFeedback(style: .light)
            }
            Button("确定", role: .destructive) {
                generateHapticFeedback(style: .heavy)
                showingSetupView = true
            }
        } message: {
            Text("确定要重新开始戒烟计时吗？这将清除所有记录。")
        }
        .sheet(isPresented: $showingSetupView) {
            SetupView(quitData: quitData, isSetupComplete: $showingSetupView)
        }
    }
    
    // 头部视图
    private var headerView: some View {
        VStack(spacing: 10) {
            Text("您已经戒烟")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(quitData.daysSinceQuit)天")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.primary)
            
            TimeDisplayView(quitData: quitData)
                .font(.title3)
                .foregroundColor(.secondary)
                
            Text("开始时间：\(quitData.quitDateFormatted)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // 进度视图
    private var progressView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("戒烟进度")
                .font(.headline)
            
            let milestones = [1, 7, 30, 90, 180, 365]
            let days = quitData.daysSinceQuit
            let (progress, nextMilestoneText) = calculateProgress(days: days, milestones: milestones)
            
            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 3, anchor: .center)
                
                HStack {
                    if days >= 365 {
                        let years = Double(days) / 365.0
                        Text(String(format: "已坚持 %.1f 年", years))
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text(nextMilestoneText)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private func calculateProgress(days: Int, milestones: [Int]) -> (progress: Double, nextMilestone: String) {
        if days >= 365 {
            let years = Double(days) / 365.0
            let nextYear = ceil(years)
            let progress = (years - floor(years)) / (nextYear - floor(years))
            return (progress, "下一个里程碑：\(Int(nextYear))年")
        } else {
            let nextMilestone = milestones.first { $0 > days } ?? milestones.last!
            let progress = min(1.0, Double(days) / Double(nextMilestone))
            return (progress, "下一个里程碑：\(nextMilestone)天")
        }
    }
    
    // 打卡视图
    private var checkInView: some View {
        VStack(spacing: 15) {
            Text("每日打卡")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: quitData.hasCheckedInToday ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 28))
                        .foregroundColor(quitData.hasCheckedInToday ? .green : .white)
                        .animation(.spring(response: 0.3), value: quitData.hasCheckedInToday)
                    
                    Text(quitData.hasCheckedInToday ? "今日已打卡" : "点击打卡")
                        .font(.system(size: 20))
                        .foregroundColor(quitData.hasCheckedInToday ? .green : .white)
                        .animation(.spring(response: 0.3), value: quitData.hasCheckedInToday)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if !quitData.hasCheckedInToday {
                        generateHapticFeedback(style: .rigid)
                        withAnimation(.spring(response: 0.3)) {
                            quitData.checkIn()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(quitData.hasCheckedInToday ? Color.green.opacity(0.15) : Color.blue)
                    .animation(.spring(response: 0.3), value: quitData.hasCheckedInToday)
            )
            
            Text("已连续打卡\(quitData.checkInDates.count)天")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    // 统计视图
    private var statisticsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("健康改善")
                .font(.headline)
                .padding(.bottom, 5)
            
            let days = quitData.daysSinceQuit
            
            VStack(alignment: .leading, spacing: 16) {
                if days >= 1 {
                    healthBenefitRow(icon: "heart.fill", color: .red, text: "血压和心率恢复正常")
                }
                
                if days >= 2 {
                    healthBenefitRow(icon: "nose.fill", color: .orange, text: "嗅觉和味觉开始恢复")
                }
                
                if days >= 14 {
                    healthBenefitRow(icon: "lungs.fill", color: .blue, text: "肺功能开始改善")
                }
                
                if days >= 30 {
                    healthBenefitRow(icon: "figure.walk", color: .green, text: "呼吸困难减轻，精力增加")
                }
                
                if days < 1 {
                    Text("继续坚持，健康改善即将开始！")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(.horizontal, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private func healthBenefitRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 24, alignment: .center)
                .accessibility(hidden: true)
            
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .padding(.vertical, 4)
            
            Spacer()
        }
    }
}

// 时间显示视图组件
struct TimeDisplayView: View {
    @ObservedObject var quitData: QuitSmokingData
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { _ in
            let time = quitData.timeSinceQuit()
            Text("\(time.hours)小时\(time.minutes)分钟\(time.seconds)秒")
        }
    }
}

// 在文件末尾添加自定义日期选择视图
struct CustomDatePickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var quitData: QuitSmokingData
    
    // 获取年份范围（从2000年到当前年份）
    private let years: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(2000...currentYear)
    }()
    
    @State private var selectedYear: Int
    @State private var selectedDateTime: Date
    
    init(selectedDate: Binding<Date>, quitData: QuitSmokingData) {
        _selectedDate = selectedDate
        self.quitData = quitData
        let calendar = Calendar.current
        _selectedYear = State(initialValue: calendar.component(.year, from: selectedDate.wrappedValue))
        _selectedDateTime = State(initialValue: selectedDate.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("选择新的戒烟开始时间")
                    .font(.headline)
                    .padding(.top)
                
                // 年份选择器
                HStack {
                    Text("选择年份：")
                        .font(.headline)
                    
                    Picker("年份", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text("\(year)年")
                                .tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100)
                    .clipped()
                    .onChange(of: selectedYear) { oldValue, newValue in
                        // 更新选择的日期，保持月日时分不变
                        let calendar = Calendar.current
                        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: selectedDateTime)
                        components.year = newValue
                        if let newDate = calendar.date(from: components) {
                            selectedDateTime = newDate
                            selectedDate = newDate
                        }
                    }
                }
                .padding()
                
                // 日期时间选择器
                DatePicker("具体时间", selection: $selectedDateTime, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .environment(\.locale, Locale(identifier: "zh_CN"))
                    .onChange(of: selectedDateTime) { oldValue, newValue in
                        selectedDate = newValue
                        // 同步更新年份选择器
                        let calendar = Calendar.current
                        selectedYear = calendar.component(.year, from: newValue)
                    }
                    .padding()
                
                Text("已选择：\(quitData.formatDate(selectedDate))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    quitData.reset(withNewDate: selectedDate)
                    dismiss()
                }) {
                    Text("确认重新开始")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
} 
