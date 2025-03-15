//
//  NoSmoke_DaysTests.swift
//  NoSmoke_DaysTests
//
//  Created by 万迎飞 on 2025/3/9.
//

import Testing
@testable import NoSmoke_Days
import Foundation

struct NoSmoke_DaysTests {

    // 在每个测试前清理UserDefaults数据
    func cleanUserDefaults() {
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    // 测试初始化和日期格式化
    @Test func testInitializationAndDateFormatting() async throws {
        cleanUserDefaults() // 清理之前的数据
        
        let testDate = Date()
        let quitData = QuitSmokingData(quitDate: testDate, loadSavedData: false) // 不加载保存的数据
        
        // 测试初始化
        #expect(quitData.quitDate == testDate)
        #expect(quitData.checkInDates.isEmpty)
        
        // 测试日期格式化
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        let expectedDateString = formatter.string(from: testDate)
        #expect(quitData.formatDate(testDate) == expectedDateString)
    }
    
    // 测试戒烟天数计算
    @Test func testDaysSinceQuit() async throws {
        cleanUserDefaults() // 清理之前的数据
        
        // 创建一个7天前的日期
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let quitData = QuitSmokingData(quitDate: sevenDaysAgo, loadSavedData: false)
        
        #expect(quitData.daysSinceQuit == 7)
    }
    
    // 测试时间计算
    @Test func testTimeSinceQuit() async throws {
        cleanUserDefaults() // 清理之前的数据
        
        // 创建一个2小时前的日期
        let twoHoursAgo = Date(timeIntervalSinceNow: -7200) // 2小时 = 7200秒
        let quitData = QuitSmokingData(quitDate: twoHoursAgo, loadSavedData: false)
        
        let time = quitData.timeSinceQuit()
        #expect(time.hours == 2)
        #expect(time.minutes >= 0 && time.minutes < 60)
        #expect(time.seconds >= 0 && time.seconds < 60)
    }
    
    // 测试打卡功能
    @Test func testCheckIn() async throws {
        cleanUserDefaults() // 清理之前的数据
        
        let quitData = QuitSmokingData(quitDate: Date(), loadSavedData: false)
        
        // 测试初始状态
        #expect(!quitData.hasCheckedInToday)
        #expect(quitData.checkInDates.isEmpty)
        
        // 测试打卡
        quitData.checkIn()
        #expect(quitData.hasCheckedInToday)
        #expect(quitData.checkInDates.count == 1)
        
        // 测试重复打卡
        quitData.checkIn()
        #expect(quitData.checkInDates.count == 1) // 不应该增加新的打卡记录
    }
    
    // 测试重置功能
    @Test func testReset() async throws {
        cleanUserDefaults() // 清理之前的数据
        
        let initialDate = Date()
        let quitData = QuitSmokingData(quitDate: initialDate, loadSavedData: false)
        
        // 添加一些打卡记录
        quitData.checkIn()
        
        // 测试重置
        let newDate = Date(timeIntervalSinceNow: 3600) // 1小时后
        quitData.reset(withNewDate: newDate)
        
        #expect(quitData.quitDate == newDate)
        #expect(quitData.checkInDates.isEmpty)
        #expect(!quitData.hasCheckedInToday)
    }
    
    // 创建测试用的UserDefaults实例
    func createTestUserDefaults() -> (UserDefaults, String) {
        let suiteName = "test_user_defaults_\(UUID().uuidString)"
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            fatalError("Failed to create test UserDefaults")
        }
        return (userDefaults, suiteName)
    }

    // 测试数据持久化
    @Test func testDataPersistence() async throws {
        let (userDefaults, suiteName) = createTestUserDefaults()
        
        let testDate = Date()
        let quitData = QuitSmokingData(quitDate: testDate, loadSavedData: false, userDefaults: userDefaults)
        
        // 保存数据前的时间戳
        let originalTimestamp = testDate.timeIntervalSince1970
        print("Original timestamp: \(originalTimestamp)")
        
        // 保存数据
        quitData.setInitialQuitDate(testDate)
        userDefaults.synchronize() // 确保数据立即写入
        
        // 验证数据是否已保存
        let savedTimestamp = userDefaults.double(forKey: "quitDate")
        print("Saved timestamp in UserDefaults: \(savedTimestamp)")
        #expect(savedTimestamp > 0, "Timestamp should be saved in UserDefaults")
        
        // 测试加载数据
        let loadedDate = quitData.loadQuitDate()
        #expect(loadedDate != nil, "Loaded date should not be nil")
        
        if let loadedDate = loadedDate {
            let loadedTimestamp = loadedDate.timeIntervalSince1970
            print("Loaded timestamp: \(loadedTimestamp)")
            
            // 比较时间戳，允许0.1秒的误差
            let timeDifference = abs(loadedTimestamp - originalTimestamp)
            print("Time difference: \(timeDifference)")
            #expect(timeDifference < 0.1, "Time difference (\(timeDifference)) should be less than 0.1 seconds")
        }
        
        // 清理测试用的UserDefaults
        UserDefaults.standard.removeSuite(named: suiteName)
    }
}
