import SwiftUI

struct SetupView: View {
    @ObservedObject var quitData: QuitSmokingData
    @Binding var isSetupComplete: Bool
    @State private var selectedDate = Date()
    @State private var showFutureTimeAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 背景色
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            // 添加一个透明的背景来接收点击事件
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    generateHapticFeedback(style: .light)
                    dismiss()
                }
            
            VStack(spacing: 0) {
                // 顶部标题区域
                VStack(spacing: 16) {
                    Text("设置您的戒烟日期")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                    
                    Image(systemName: "lungs")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .padding(.vertical, 10)
                }
                .padding(.bottom, 30)
                
                // 日期选择区域
                VStack(spacing: 25) {
                    Text("选择您开始戒烟的日期和时间")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // 日期选择器容器
                    VStack(spacing: 15) {
                        DatePicker("戒烟日期", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .environment(\.locale, Locale(identifier: "zh_CN"))
                        
                        Text("已选择：\(quitData.formatDate(selectedDate))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 底部按钮区域
                VStack(spacing: 16) {
                    Button(action: {
                        generateHapticFeedback(style: .rigid)
                        
                        // 检查选择的时间是否在未来
                        if selectedDate > Date() {
                            // 显示提示，不允许设置未来时间
                            showFutureTimeAlert = true
                        } else {
                            // 设置戒烟时间并关闭视图
                            quitData.reset(withNewDate: selectedDate)
                            isSetupComplete = true
                            dismiss()
                        }
                    }) {
                        Text("开始我的戒烟之旅")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue)
                            )
                    }
                    
                    Text("向下滑动以取消")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            // 阻止 VStack 内部的点击事件传递到背景
            .onTapGesture { }
        }
        .alert(isPresented: $showFutureTimeAlert) {
            Alert(title: Text("提示"), message: Text("请选择过去的时间"), dismissButton: .default(Text("确定")))
        }
    }
} 