import Foundation

class QuitSmokingData: ObservableObject {
    @Published var quitDate: Date
    @Published var checkInDates: [Date] = []
    
    init(quitDate: Date = Date()) {
        self.quitDate = quitDate
        loadCheckInDates()
    }
    
    // 格式化日期为中文格式
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
    
    // 计算戒烟天数
    var daysSinceQuit: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: quitDate, to: Date())
        return max(0, components.day ?? 0)
    }
    
    // 计算戒烟时间（小时、分钟、秒）
    func timeSinceQuit() -> (hours: Int, minutes: Int, seconds: Int) {
        let timeInterval = Date().timeIntervalSince(quitDate)
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        let seconds = Int(timeInterval) % 60
        return (hours, minutes, seconds)
    }
    
    // 获取戒烟开始日期的中文格式
    var quitDateFormatted: String {
        return formatDate(quitDate)
    }
    
    // 检查今天是否已经打卡
    var hasCheckedInToday: Bool {
        let calendar = Calendar.current
        return checkInDates.contains { date in
            calendar.isDate(date, inSameDayAs: Date())
        }
    }
    
    // 执行打卡
    func checkIn() {
        if !hasCheckedInToday {
            let now = Date()
            checkInDates.append(now)
            saveCheckInDates()
        }
    }
    
    // 设置初始戒烟日期
    func setInitialQuitDate(_ date: Date) {
        quitDate = date
        saveQuitDate()
    }
    
    // 重置所有数据
    func reset(withNewDate date: Date) {
        quitDate = date
        checkInDates = []
        saveQuitDate()
        saveCheckInDates()
    }
    
    // 保存打卡记录
    private func saveCheckInDates() {
        if let encoded = try? JSONEncoder().encode(checkInDates) {
            UserDefaults.standard.set(encoded, forKey: "checkInDates")
        }
    }
    
    // 加载打卡记录
    private func loadCheckInDates() {
        if let savedDates = UserDefaults.standard.data(forKey: "checkInDates"),
           let decodedDates = try? JSONDecoder().decode([Date].self, from: savedDates) {
            checkInDates = decodedDates
        }
    }
    
    // 保存戒烟日期
    private func saveQuitDate() {
        UserDefaults.standard.set(quitDate, forKey: "quitDate")
    }
    
    // 加载戒烟日期
    func loadQuitDate() -> Date? {
        return UserDefaults.standard.object(forKey: "quitDate") as? Date
    }
} 