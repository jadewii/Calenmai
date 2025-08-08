//
//  SettingsView.swift
//  Todomai-iOS
//
//  Settings page with custom Todomai UI style
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var taskStore: TaskStore
    @Binding var currentTab: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    Text("SETTINGS")
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(.black)
                        .padding(.top, 60)
                        .padding(.bottom, 40)
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            // Current Mode Info
                            VStack(spacing: 12) {
                                Text("CURRENT MODE")
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(.black)
                                
                                Text(taskStore.currentMode.displayName)
                                    .font(.system(size: 24, weight: .heavy))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        ZStack {
                                            taskStore.currentMode.modeButtonColor
                                            Rectangle()
                                                .stroke(Color.black, lineWidth: 3)
                                        }
                                    )
                            }
                            .padding(.horizontal, 40)
                            
                            // Day Schedule Settings
                            VStack(spacing: 12) {
                                Text("DAY SCHEDULE")
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(.black)
                                    .padding(.top, 20)
                                
                                // Day start and end time pickers
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Day Starts:")
                                            .font(.system(size: 14, weight: .bold))
                                        Spacer()
                                        Text("5:00 AM")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        Text("Day Ends:")
                                            .font(.system(size: 14, weight: .bold))
                                        Spacer()
                                        Text("12:00 AM")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                    .background(
                                        ZStack {
                                            Color.gray.opacity(0.1)
                                            Rectangle()
                                                .stroke(Color.black, lineWidth: 3)
                                        }
                                    )
                            }
                            .padding(.horizontal, 40)
                            
                            // Statistics
                            VStack(spacing: 12) {
                                Text("STATISTICS")
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(.black)
                                    .padding(.top, 20)
                                
                                HStack {
                                    StatBox(title: "TOTAL", value: "\(taskStore.tasks.count)", color: Color(red: 0.4, green: 0.8, blue: 1.0))
                                    StatBox(title: "COMPLETED", value: "\(taskStore.tasks.filter { $0.isCompleted }.count)", color: Color(red: 0.4, green: 0.8, blue: 0.4))
                                }
                                
                                HStack {
                                    StatBox(title: "PENDING", value: "\(taskStore.tasks.filter { !$0.isCompleted }.count)", color: Color(red: 1.0, green: 0.7, blue: 0.3))
                                    StatBox(title: "TODAY", value: "\(taskStore.tasks.filter { $0.listId == "today" && !$0.isCompleted }.count)", color: Color(red: 1.0, green: 0.431, blue: 0.431))
                                }
                            }
                            .padding(.horizontal, 40)
                            
                            // About Section
                            VStack(spacing: 12) {
                                Text("ABOUT")
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(.black)
                                    .padding(.top, 20)
                                
                                VStack(spacing: 4) {
                                    Text("TODOMAI")
                                        .font(.system(size: 24, weight: .heavy))
                                        .foregroundColor(.black)
                                    Text("VERSION 1.0")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.gray)
                                    Text("© 2025")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(
                                    ZStack {
                                        Color.gray.opacity(0.1)
                                        Rectangle()
                                            .stroke(Color.black, lineWidth: 3)
                                    }
                                )
                            }
                            .padding(.horizontal, 40)
                            
                            // Clear Data Button
                            Button(action: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                taskStore.clearCompleted()
                            }) {
                                Text("CLEAR COMPLETED TASKS")
                                    .font(.system(size: 16, weight: .heavy))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(
                                        ZStack {
                                            Color.red
                                            Rectangle()
                                                .stroke(Color.black, lineWidth: 3)
                                        }
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                        }
                        .padding(.bottom, 40)
                    }
                    
                    // Back button
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        currentTab = "menu"
                    }) {
                        Text("← BACK")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                ZStack {
                                    Color.white
                                    Rectangle()
                                        .stroke(Color.black, lineWidth: 3)
                                }
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(.black)
            
            Text(value)
                .font(.system(size: 28, weight: .heavy))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    ZStack {
                        color
                        Rectangle()
                            .stroke(Color.black, lineWidth: 3)
                    }
                )
        }
    }
}

#Preview {
    SettingsView(taskStore: TaskStore(), currentTab: .constant("settings"))
}