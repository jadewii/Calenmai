//
//  DayScheduleView.swift
//  Calemai
//
//  Hour-by-hour block schedule view
//

import SwiftUI

struct DayScheduleView: View {
    @EnvironmentObject var taskStore: TaskStore
    @State private var dayStartHour: Int = 5 // 5:00 AM default
    @State private var dayEndHour: Int = 24 // 12:00 AM (midnight)
    
    // Use taskStore's selected calendar date for reactive updates
    var selectedDate: Date {
        taskStore.selectedCalendarDate ?? Date()
    }
    
    var body: some View {
        ZStack {
            // Background based on current mode
            taskStore.currentMode.modeButtonColor.opacity(0.05)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with current date - matching app style
                VStack(spacing: 0) {
                    Text(formatDate(selectedDate))
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.gray)
                        .padding(.top, 12)
                    
                    // Navigation buttons - matching app style
                    HStack(spacing: 12) {
                        Button(action: previousDay) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .heavy))
                                Text("PREV")
                                    .font(.system(size: 14, weight: .heavy))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                ZStack {
                                    taskStore.currentMode.modeButtonColor
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 2)
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: { 
                            taskStore.selectedCalendarDate = Date()
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                        }) {
                            Text("TODAY")
                                .font(.system(size: 14, weight: .heavy))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(
                                    ZStack {
                                        Color(red: 0.4, green: 0.8, blue: 1.0)
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.black, lineWidth: 2)
                                    }
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: nextDay) {
                            HStack {
                                Text("NEXT")
                                    .font(.system(size: 14, weight: .heavy))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .heavy))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                ZStack {
                                    taskStore.currentMode.modeButtonColor
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray, lineWidth: 2)
                                }
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 12)
                }
                .background(
                    ZStack {
                        Color.white
                        Rectangle()
                            .stroke(Color.gray, lineWidth: 2)
                    }
                )
                
                // Scrollable timeline with app styling
                ScrollView {
                    VStack(spacing: 1) {
                        ForEach(dayStartHour..<dayEndHour, id: \.self) { hour in
                            TimeBlockView(
                                hour: hour,
                                tasks: tasksForHour(hour),
                                taskStore: taskStore,
                                selectedDate: selectedDate
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                }
                .background(Color.white)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date).uppercased()
    }
    
    private func previousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            taskStore.selectedCalendarDate = newDate
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    private func nextDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            taskStore.selectedCalendarDate = newDate
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
    
    private func tasksForHour(_ hour: Int) -> [Task] {
        let calendar = Calendar.current
        
        return taskStore.tasks.filter { task in
            // Check if task is for selected date
            guard let taskDate = task.dueDate else { return false }
            
            if !calendar.isDate(taskDate, inSameDayAs: selectedDate) {
                return false
            }
            
            // Check if task falls within this hour
            let taskHour = calendar.component(.hour, from: taskDate)
            return taskHour == hour
        }
    }
}

struct TimeBlockView: View {
    let hour: Int
    let tasks: [Task]
    @ObservedObject var taskStore: TaskStore
    let selectedDate: Date
    
    var isCurrentHour: Bool {
        let calendar = Calendar.current
        let now = Date()
        return calendar.isDate(selectedDate, inSameDayAs: now) && calendar.component(.hour, from: now) == hour
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Time label with heavy font
            Text(formatHour(hour))
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(isCurrentHour ? taskStore.currentMode.modeButtonColor : .gray)
                .frame(width: 70, alignment: .trailing)
                .padding(.trailing, 8)
            
            // Bold divider line
            Rectangle()
                .fill(isCurrentHour ? taskStore.currentMode.modeButtonColor : Color.gray)
                .frame(width: 2)
            
            // Task area with app styling
            VStack(alignment: .leading, spacing: 4) {
                if tasks.isEmpty {
                    // Empty hour block with app style
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.05))
                            .overlay(
                                Rectangle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        
                        Text("—")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(.gray.opacity(0.2))
                    }
                    .frame(height: 56)
                } else {
                    // Show tasks for this hour with app styling
                    ForEach(tasks) { task in
                        TaskBlockView(task: task, taskStore: taskStore)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
        }
        .frame(minHeight: 60)
        .background(
            ZStack {
                if isCurrentHour {
                    taskStore.currentMode.modeButtonColor.opacity(0.1)
                } else {
                    Color.white
                }
                Rectangle()
                    .stroke(Color.gray, lineWidth: 1)
            }
        )
    }
    
    func formatHour(_ hour: Int) -> String {
        if hour == 0 || hour == 24 {
            return "12 AM"
        } else if hour < 12 {
            return "\(hour) AM"
        } else if hour == 12 {
            return "12 PM"
        } else {
            return "\(hour - 12) PM"
        }
    }
}

struct TaskBlockView: View {
    let task: Task
    @ObservedObject var taskStore: TaskStore
    
    var body: some View {
        HStack {
            // Bold task color indicator
            Rectangle()
                .fill(task.urgencyColor)
                .frame(width: 6)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.text)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(task.isCompleted ? Color.gray.opacity(0.5) : .gray)
                    .strikethrough(task.isCompleted)
                    .lineLimit(2)
                
                if let time = task.dueDate {
                    Text(formatTime(time))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 4)
            
            Spacer()
            
            // Completion checkbox with app styling
            Button(action: { 
                taskStore.toggleTask(task)
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }) {
                ZStack {
                    Circle()
                        .stroke(Color.gray, lineWidth: 2)
                        .background(
                            Circle()
                                .fill(task.isCompleted ? Color.green : Color.white)
                        )
                        .frame(width: 24, height: 24)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            ZStack {
                getTaskBackgroundColor()
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.gray, lineWidth: 2)
            }
        )
    }
    
    func getTaskBackgroundColor() -> Color {
        // Use mode colors with higher visibility
        switch task.mode {
        case "life":
            return Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.2)
        case "work":
            return Color.green.opacity(0.2)
        case "school":
            return Color.purple.opacity(0.2)
        default:
            return Color.gray.opacity(0.1)
        }
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Settings view extension for day start time
struct DayScheduleSettings: View {
    @AppStorage("dayStartHour") private var dayStartHour = 5
    @AppStorage("dayEndHour") private var dayEndHour = 24
    
    var body: some View {
        Section(header: Text("Day Schedule")) {
            Picker("Day Starts At", selection: $dayStartHour) {
                ForEach(0..<12) { hour in
                    Text(formatHour(hour)).tag(hour)
                }
            }
            
            Picker("Day Ends At", selection: $dayEndHour) {
                ForEach(13..<25) { hour in
                    Text(formatHour(hour)).tag(hour)
                }
            }
        }
    }
    
    func formatHour(_ hour: Int) -> String {
        if hour == 0 || hour == 24 {
            return "12:00 AM"
        } else if hour < 12 {
            return "\(hour):00 AM"
        } else if hour == 12 {
            return "12:00 PM"
        } else {
            return "\(hour - 12):00 PM"
        }
    }
}