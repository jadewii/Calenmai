import SwiftUI

struct CalemaiCalendarView: View {
    @ObservedObject var taskStore: TaskStore
    @State private var selectedDate = Date()
    @State private var viewMode: CalendarViewMode = .month
    
    enum CalendarViewMode {
        case month, week, day
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with navigation
            CalendarHeaderView(
                selectedDate: $selectedDate,
                viewMode: $viewMode
            )
            .padding()
            .background(Color.purple.opacity(0.1))
            
            // View mode selector
            Picker("View Mode", selection: $viewMode) {
                Text("Month").tag(CalendarViewMode.month)
                Text("Week").tag(CalendarViewMode.week)
                Text("Day").tag(CalendarViewMode.day)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Calendar content based on mode
            ScrollView {
                switch viewMode {
                case .month:
                    MonthGridView(selectedDate: $selectedDate, taskStore: taskStore)
                case .week:
                    WeekTimelineView(selectedDate: $selectedDate, taskStore: taskStore)
                case .day:
                    DayScheduleView(selectedDate: $selectedDate, taskStore: taskStore)
                }
            }
        }
        .navigationTitle("Calendar")
    }
}

struct CalendarHeaderView: View {
    @Binding var selectedDate: Date
    @Binding var viewMode: CalemaiCalendarView.CalendarViewMode
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = viewMode == .month ? "MMMM yyyy" : "MMM d, yyyy"
        return formatter
    }
    
    var body: some View {
        HStack {
            Button(action: previousPeriod) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
            
            Spacer()
            
            Text(dateFormatter.string(from: selectedDate))
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            Button(action: nextPeriod) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.purple)
            }
        }
    }
    
    func previousPeriod() {
        withAnimation {
            switch viewMode {
            case .month:
                selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
            case .week:
                selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
            case .day:
                selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
            }
        }
    }
    
    func nextPeriod() {
        withAnimation {
            switch viewMode {
            case .month:
                selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
            case .week:
                selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
            case .day:
                selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
            }
        }
    }
}

struct MonthGridView: View {
    @Binding var selectedDate: Date
    @ObservedObject var taskStore: TaskStore
    
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack {
            // Weekday headers
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayCell(date: date, isSelected: isSameDay(date), taskStore: taskStore)
                            .onTapGesture {
                                selectedDate = date
                            }
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
                }
            }
            .padding()
        }
    }
    
    func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? Date()
        let numberOfDays = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in 1...numberOfDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // Fill remaining cells
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    func isSameDay(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    @ObservedObject var taskStore: TaskStore
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    var tasksForDay: [Task] {
        taskStore.tasks.filter { task in
            if let dueDate = task.dueDate {
                return Calendar.current.isDate(dueDate, inSameDayAs: date)
            }
            return false
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(dayFormatter.string(from: date))
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .white : .primary)
            
            if !tasksForDay.isEmpty {
                HStack(spacing: 2) {
                    ForEach(0..<min(3, tasksForDay.count), id: \.self) { _ in
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.purple : Color.gray.opacity(0.1))
        )
    }
}

struct WeekTimelineView: View {
    @Binding var selectedDate: Date
    @ObservedObject var taskStore: TaskStore
    
    let hours = Array(0...23)
    
    var body: some View {
        VStack {
            // Week days header
            WeekDaysHeader(selectedDate: selectedDate)
            
            // Hourly timeline
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(hours, id: \.self) { hour in
                            HourRow(hour: hour, selectedDate: selectedDate, taskStore: taskStore)
                                .id(hour)
                        }
                    }
                }
                .onAppear {
                    // Scroll to current hour
                    let currentHour = Calendar.current.component(.hour, from: Date())
                    withAnimation {
                        proxy.scrollTo(currentHour, anchor: .top)
                    }
                }
            }
        }
        .padding()
    }
}

struct WeekDaysHeader: View {
    let selectedDate: Date
    
    var weekDays: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? Date()
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    var body: some View {
        HStack {
            Text("Time")
                .frame(width: 60)
                .font(.caption)
            
            ForEach(weekDays, id: \.self) { date in
                VStack {
                    Text(date, format: .dateTime.weekday(.abbreviated))
                        .font(.caption)
                    Text(date, format: .dateTime.day())
                        .font(.caption2)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
    }
}

struct HourRow: View {
    let hour: Int
    let selectedDate: Date
    @ObservedObject var taskStore: TaskStore
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(hour):00")
                .font(.caption)
                .frame(width: 60)
                .foregroundColor(.gray)
            
            Divider()
            
            // Events for this hour
            HStack {
                ForEach(getWeekDays(), id: \.self) { date in
                    EventsForHour(date: date, hour: hour, taskStore: taskStore)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(height: 60)
        .overlay(
            Divider(),
            alignment: .bottom
        )
    }
    
    func getWeekDays() -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? Date()
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
}

struct EventsForHour: View {
    let date: Date
    let hour: Int
    @ObservedObject var taskStore: TaskStore
    
    var tasksForHour: [Task] {
        taskStore.tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            let calendar = Calendar.current
            return calendar.isDate(dueDate, inSameDayAs: date) &&
                   calendar.component(.hour, from: dueDate) == hour
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(tasksForHour) { task in
                Text(task.text)
                    .font(.caption2)
                    .lineLimit(2)
                    .padding(4)
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(4)
            }
        }
    }
}

struct DayScheduleView: View {
    @Binding var selectedDate: Date
    @ObservedObject var taskStore: TaskStore
    
    let hours = Array(0...23)
    
    var body: some View {
        VStack {
            Text(selectedDate, format: .dateTime.weekday(.wide).month().day())
                .font(.title2)
                .fontWeight(.bold)
                .padding()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(hours, id: \.self) { hour in
                            DayHourRow(hour: hour, date: selectedDate, taskStore: taskStore)
                                .id(hour)
                        }
                    }
                }
                .onAppear {
                    let currentHour = Calendar.current.component(.hour, from: Date())
                    withAnimation {
                        proxy.scrollTo(currentHour, anchor: .top)
                    }
                }
            }
        }
        .padding()
    }
}

struct DayHourRow: View {
    let hour: Int
    let date: Date
    @ObservedObject var taskStore: TaskStore
    
    var tasksForHour: [Task] {
        taskStore.tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            let calendar = Calendar.current
            return calendar.isDate(dueDate, inSameDayAs: date) &&
                   calendar.component(.hour, from: dueDate) == hour
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text(String(format: "%02d:00", hour))
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 50)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 4) {
                if tasksForHour.isEmpty {
                    Rectangle()
                        .fill(Color.gray.opacity(0.05))
                        .frame(height: 50)
                } else {
                    ForEach(tasksForHour) { task in
                        HStack {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 8, height: 8)
                            
                            Text(task.text)
                                .font(.system(size: 14))
                            
                            Spacer()
                            
                            if let dueDate = task.dueDate {
                                Text(dueDate, format: .dateTime.hour().minute())
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(8)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(minHeight: 60)
    }
}