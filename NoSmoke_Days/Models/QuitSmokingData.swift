import Foundation

class QuitSmokingData: ObservableObject {
    @Published var quitDate: Date
    @Published var checkInDates: [Date] = []
    private let userDefaults: UserDefaults
    
    init(quitDate: Date = Date()) {
        self.quitDate = quitDate
        self.userDefaults = UserDefaults.standard
        loadCheckInDates()
    }
    
    // 用于测试的初始化方法
    init(quitDate: Date = Date(), loadSavedData: Bool = true, userDefaults: UserDefaults = .standard) {
        self.quitDate = quitDate
        self.userDefaults = userDefaults
        if loadSavedData {
            loadCheckInDates()
        }
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
    
    // 检查是否可以打卡
    var canCheckIn: Bool {
        // 如果今天已经打卡，则不能再次打卡
        if hasCheckedInToday {
            return false
        }
        
        // 检查总戒烟时间是否大于24小时
        let hoursSinceQuit = Date().timeIntervalSince(quitDate) / 3600
        if hoursSinceQuit < 24 {
            return false
        }
        
        // 如果有打卡记录，检查距离上次打卡是否已经过了24小时
        if let lastCheckInDate = checkInDates.last {
            let hoursSinceLastCheckIn = Date().timeIntervalSince(lastCheckInDate) / 3600
            return hoursSinceLastCheckIn >= 24
        }
        
        // 如果没有打卡记录，且戒烟时间大于24小时，则可以打卡
        return true
    }
    
    // 获取下次可打卡时间
    var nextCheckInTime: Date? {
        // 如果可以打卡，返回nil
        if canCheckIn {
            return nil
        }
        
        // 如果戒烟时间不足24小时，返回戒烟时间+24小时
        let hoursSinceQuit = Date().timeIntervalSince(quitDate) / 3600
        if hoursSinceQuit < 24 {
            return quitDate.addingTimeInterval(24 * 3600)
        }
        
        // 如果有打卡记录，返回上次打卡时间+24小时
        if let lastCheckInDate = checkInDates.last {
            let nextDate = lastCheckInDate.addingTimeInterval(24 * 3600)
            
            // 如果下次打卡时间在今天，但今天已经打卡，则返回明天相同时间
            if hasCheckedInToday {
                let calendar = Calendar.current
                if calendar.isDateInToday(nextDate) {
                    // 计算明天相同时间
                    if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) {
                        let todayComponents = calendar.dateComponents([.hour, .minute, .second], from: nextDate)
                        let tomorrowDate = calendar.date(bySettingHour: todayComponents.hour ?? 0,
                                                        minute: todayComponents.minute ?? 0,
                                                        second: todayComponents.second ?? 0,
                                                        of: tomorrow) ?? tomorrow
                        return tomorrowDate
                    }
                }
            }
            
            return nextDate
        }
        
        return nil
    }
    
    // 执行打卡
    func checkIn() {
        if canCheckIn {
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
            userDefaults.set(encoded, forKey: "checkInDates")
            userDefaults.synchronize()
        }
    }
    
    // 加载打卡记录
    private func loadCheckInDates() {
        if let savedDates = userDefaults.data(forKey: "checkInDates"),
           let decodedDates = try? JSONDecoder().decode([Date].self, from: savedDates) {
            checkInDates = decodedDates
        }
    }
    
    // 保存戒烟日期
    private func saveQuitDate() {
        let timestamp = quitDate.timeIntervalSince1970
        userDefaults.set(timestamp, forKey: "quitDate")
        userDefaults.synchronize()
    }
    
    // 加载戒烟日期
    func loadQuitDate() -> Date? {
        let timestamp = userDefaults.double(forKey: "quitDate")
        if timestamp > 0 {  // 确保时间戳是有效的
            return Date(timeIntervalSince1970: timestamp)
        }
        return nil
    }
}