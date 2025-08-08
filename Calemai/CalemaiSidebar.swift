//
//  CalemaiSidebar.swift
//  Calemai
//
//  Custom sidebar with Calemai UI style - calendar-focused navigation
//

import SwiftUI

struct CalemaiSidebar: View {
    @ObservedObject var taskStore: TaskStore
    @Binding var currentTab: String
    
    var isColoredBackground: Bool {
        // Check if current view has a colored background
        switch currentTab {
        case "today":
            return false // White background
        case "calendar", "thisWeek", "later", "routines", "appointments", "radio", "settings":
            return true // Colored backgrounds
        default:
            return false
        }
    }
    
    var sidebarItems: [(id: String, title: String, color: Color)] {
        var items: [(id: String, title: String, color: Color)] = []
        
        // Main navigation items
        switch taskStore.currentMode {
        case .life:
            items = [
                ("calendar", "📅 CALENDAR", Color.purple),
                ("today", "TODAY", Color(red: 0.4, green: 0.8, blue: 1.0)),
                ("thisWeek", "THIS WEEK", Color(red: 0.478, green: 0.686, blue: 0.961)),
                ("later", "TO-DO LIST", Color(red: 0.859, green: 0.835, blue: 0.145)),
                ("getItDone", "GET IT DONE!", Color.red),
                ("routines", "ROUTINES", Color(red: 0.8, green: 0.8, blue: 1.0)),
                ("appointments", "APPOINTMENTS", Color(red: 0.8, green: 0.6, blue: 1.0)),
                ("settings", "SETTINGS", Color(red: 0.6, green: 0.6, blue: 0.6))
            ]
        case .work:
            items = [
                ("calendar", "📅 CALENDAR", Color.purple),
                ("today", "TODAY", Color.orange),
                ("week", "THIS WEEK", Color(red: 1.0, green: 0.5, blue: 0.0)),
                ("month", "THIS MONTH", Color(red: 1.0, green: 0.7, blue: 0.3)),
                ("getItDone", "GET IT DONE!", Color.red),
                ("routines", "ROUTINES", Color(red: 0.8, green: 0.8, blue: 1.0)),
                ("appointments", "APPOINTMENTS", Color(red: 0.8, green: 0.6, blue: 1.0)),
                ("settings", "SETTINGS", Color(red: 0.6, green: 0.6, blue: 0.6))
            ]
        case .school:
            items = [
                ("calendar", "📅 CALENDAR", Color.purple),
                ("today", "TODAY", Color(red: 0.6, green: 0.4, blue: 1.0)),
                ("assignments", "ASSIGNMENTS", Color(red: 0.5, green: 0.3, blue: 0.8)),
                ("exams", "EXAMS", Color(red: 0.7, green: 0.2, blue: 0.9)),
                ("getItDone", "GET IT DONE!", Color.red),
                ("routines", "ROUTINES", Color(red: 0.8, green: 0.8, blue: 1.0)),
                ("appointments", "APPOINTMENTS", Color(red: 0.8, green: 0.6, blue: 1.0)),
                ("settings", "SETTINGS", Color(red: 0.6, green: 0.6, blue: 0.6))
            ]
        }
        
        // Don't add secondary items - they're now in the main list
        
        return items
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 0) {
                // Mode header with Todomai style
                Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                taskStore.cycleThroughModes()
            }) {
                HStack {
                    Text(taskStore.currentMode.displayName)
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundColor(isColoredBackground ? .white : .black)
                        .animation(nil, value: taskStore.currentMode)
                    Spacer()
                    ZStack {
                        Circle()
                            .fill(taskStore.currentMode.modeButtonColor)
                            .frame(width: 40, height: 40)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 12, height: 12)
                    }
                    .animation(nil, value: taskStore.currentMode)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 30)
            }
            .buttonStyle(PlainButtonStyle())
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(sidebarItems, id: \.id) { item in
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            currentTab = item.id
                        }) {
                            Text(item.title)
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundColor(currentTab == item.id ? .white : .black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    Group {
                                        if currentTab == item.id {
                                            // Darken the color when selected
                                            item.color
                                                .overlay(Color.black.opacity(0.3))
                                        } else {
                                            item.color
                                        }
                                    }
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .animation(nil, value: currentTab) // Remove animation
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Bottom buttons - RADIO and CALENDAR
            VStack(spacing: 12) {
                // RADIO button
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    currentTab = "radio"
                }) {
                    Text("RADIO")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(currentTab == "radio" ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            Group {
                                let radioColor = Color(red: 0.4, green: 0.9, blue: 0.6)
                                if currentTab == "radio" {
                                    radioColor.overlay(Color.black.opacity(0.3))
                                } else {
                                    radioColor
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                // CALENDAR button
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    currentTab = "calendar"
                }) {
                    Text("CALENDAR")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(currentTab == "calendar" ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            Group {
                                let calendarColor = Color(red: 1.0, green: 0.431, blue: 0.431)
                                if currentTab == "calendar" {
                                    calendarColor.overlay(Color.black.opacity(0.3))
                                } else {
                                    calendarColor
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
            .animation(nil, value: taskStore.currentMode) // Remove animation when mode changes
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
        .background(
            VStack(spacing: 0) {
                taskStore.currentMode.modeButtonColor
                    .frame(height: 20)
                Color.clear
            }
        )
    }
}