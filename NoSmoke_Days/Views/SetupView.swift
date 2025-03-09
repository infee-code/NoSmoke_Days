import SwiftUI

struct SetupView: View {
    @ObservedObject var quitData: QuitSmokingData
    @Binding var isSetupComplete: Bool
    @State private var selectedDate = Date()
    
    var body: some View {
        VStack(spacing: 30) {
            Text("设置您的戒烟日期")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Image(systemName: "lungs")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("选择您开始戒烟的日期和时间")
                .font(.headline)
            
            DatePicker("戒烟日期", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "zh_CN"))
                .padding()
            
            Text("已选择：\(quitData.formatDate(selectedDate))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                quitData.setInitialQuitDate(selectedDate)
                isSetupComplete = true
            }) {
                Text("开始我的戒烟之旅")
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
    }
} 