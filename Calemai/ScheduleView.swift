//
//  ScheduleView.swift
//  Calemai
//
//  Weekly schedule view with columns for each day
//

import SwiftUI

struct ScheduleView: View {
    @ObservedObject var taskStore: TaskStore
    @Binding var currentTab: String
    
    @State private var currentWeek = Date()
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header with week navigation
                HStack {
                    Button(action: previousWeek) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .padding(.leading)
                    
                    Spacer()
                    
                    Text(weekRangeText())
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: nextWeek) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical, 12)
                .background(Color.gray.opacity(0.1))
                
                // Days of week grid
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(0..<7) { dayIndex in
                            DayColumnView(
                                date: dateForDayOfWeek(dayIndex),
                                taskStore: taskStore,
                                isToday: isToday(dateForDayOfWeek(dayIndex))
                            )
                            .frame(width: max(200, geometry.size.width / 5))
                            
                            if dayIndex < 6 {
                                Divider()
                            }
                        }
                    }
                }
                
                // Bottom section with lists
                ScrollView {
                    VStack(spacing: 20) {
                        // Category sections
                        HStack(alignment: .top, spacing: 16) {
                            CategorySection(title: "SOMEDAY", tasks: taskStore.tasks.filter { $0.listId == "later" && !$0.isCompleted }, taskStore: taskStore)
                            CategorySection(title: "WISHLIST", tasks: [], taskStore: taskStore)
                            CategorySection(title: "MOVIES TO WATCH", tasks: [], taskStore: taskStore)
                            CategorySection(title: "IDEAS", tasks: [], taskStore: taskStore)
                            CategorySection(title: "GROCERIES", tasks: [], taskStore: taskStore)
                        }
                        .padding()
                    }
                }
                .frame(height: geometry.size.height * 0.3)
                .background(Color.gray.opacity(0.05))
            }
        }
        .background(Color.white)
    }
    
    private func previousWeek() {
        if let newWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeek) {
            currentWeek = newWeek
        }
    }
    
    private func nextWeek() {
        if let newWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeek) {
            currentWeek = newWeek
        }
    }
    
    private func weekRangeText() -> String {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentWeek)?.start ?? currentWeek
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? currentWeek
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    private func dateForDayOfWeek(_ dayIndex: Int) -> Date {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: currentWeek)?.start ?? currentWeek
        return calendar.date(byAdding: .day, value: dayIndex, to: startOfWeek) ?? currentWeek
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
}

struct DayColumnView: View {
    let date: Date
    @ObservedObject var taskStore: TaskStore
    let isToday: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 0) {
            // Day header
            VStack(spacing: 4) {
                Text(dayName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isToday ? .red : .primary)
                
                Text(dateText)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isToday ? Color.red.opacity(0.1) : Color.clear)
            
            Divider()
            
            // Tasks for this day
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(tasksForDay) { task in
                        TaskRowView(task: task, taskStore: taskStore)
                    }
                    
                    // Add task button
                    Button(action: {
                        // Add new task for this day
                    }) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add item")
                        }
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).uppercased()
    }
    
    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date).uppercased()
    }
    
    private var tasksForDay: [Task] {
        taskStore.tasks.filter { task in
            guard let taskDate = task.dueDate else { return false }
            return calendar.isDate(taskDate, inSameDayAs: date) && !task.isCompleted
        }
    }
}

struct TaskRowView: View {
    let task: Task
    @ObservedObject var taskStore: TaskStore
    
    var body: some View {
        HStack {
            Button(action: {
                taskStore.toggleTask(task)
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
            
            Text(task.text)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .strikethrough(task.isCompleted)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
}

struct CategorySection: View {
    let title: String
    let tasks: [Task]
    @ObservedObject var taskStore: TaskStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(tasks.prefix(3)) { task in
                    HStack {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 12))
                            .foregroundColor(task.isCompleted ? .green : .gray)
                        
                        Text(task.text)
                            .font(.system(size: 12))
                            .lineLimit(1)
                    }
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add item")
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                }
            }
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ScheduleView(taskStore: TaskStore(), currentTab: .constant("schedule"))
}