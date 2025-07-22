//
//  TodomaiApp.swift
//  Todomai Watch App
//
//  Created by jade on 7/10/25.
//

import SwiftUI
import AVFoundation

@main
struct TodomaiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            // Add keyboard shortcuts for macOS
            CommandGroup(replacing: .newItem) {
                Button("New Task") {
                    // TODO: Implement new task creation
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        #endif
    }
}

struct Task: Identifiable, Codable {
    let id: UUID
    var text: String
    var isCompleted: Bool
    var createdAt: Date
    var listId: String
    var mode: String
    var dueDate: Date?
    var assignedTo: String?
    var isRecurring: Bool
    var comments: [String]
    var rewardStars: Int
    var hasReminder: Bool
    var reminderMinutesBefore: Int?
    
    init(text: String, isCompleted: Bool = false, listId: String = "today", mode: String = "life") {
        self.id = UUID()
        self.text = text
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.listId = listId
        self.mode = mode
        self.dueDate = nil
        self.assignedTo = nil
        self.isRecurring = false
        self.comments = []
        self.rewardStars = 0
        self.hasReminder = false
        self.reminderMinutesBefore = nil
    }
    
    var urgencyColor: Color {
        guard let dueDate = dueDate else { return .white }
        
        let now = Date()
        let calendar = Calendar.current
        
        if dueDate < now {
            return .red // Overdue
        } else if calendar.isDateInToday(dueDate) {
            return .orange // Due today
        } else if calendar.isDate(dueDate, equalTo: now, toGranularity: .weekOfYear) {
            return .yellow // Due this week
        } else {
            return .white // No urgency
        }
    }
}

struct TaskList: Identifiable, Codable {
    let id: String
    var name: String
    var color: Color.RGBValues
    
    var swiftUIColor: Color {
        Color(red: color.red, green: color.green, blue: color.blue)
    }
}

// 4-Mode System
enum ViewMode: String, CaseIterable, Codable {
    case life = "life"
    case work = "work"
    case school = "school"
    
    var displayName: String {
        switch self {
        case .life: return "LIFE"
        case .work: return "WORK"
        case .school: return "SCHOOL"
        }
    }
    
    var modeButtonColor: Color {
        switch self {
        case .life: return .blue
        case .work: return .green
        case .school: return Color(red: 0.784, green: 0.647, blue: 0.949) // #c8a5f2
        }
    }
    
    func getListIds() -> [String] {
        // Return three buttons: TODAY, THIS WEEK, and SCHEDULED (SOMEDAY is hidden)
        return ["today", "thisWeek", "done"]
    }
    
    func getListName(for id: String) -> String {
        switch id {
        case "today": return "TODAY"
        case "thisWeek": return "THIS WEEK"
        case "later": return "SOMEDAY"
        case "done": return "CALENDAR"
        default: return id.uppercased()
        }
    }
    
    func getListColor(for id: String) -> Color {
        switch self {
        case .life:
            switch id {
            case "today": return self.modeButtonColor // Blue for LIFE mode
            case "thisWeek": return Color(red: 0.478, green: 0.686, blue: 0.961) // #7aaff5
            case "later": return Color(red: 1.0, green: 0.6, blue: 0.0) // Orange
            case "done": return Color(red: 1.0, green: 0.7, blue: 0.7) // Pastel red for urgency
            default: return .gray
            }
        case .work:
            switch id {
            case "today": return self.modeButtonColor // Green for WORK mode
            case "thisWeek": return Color(red: 0.478, green: 0.686, blue: 0.961) // #7aaff5
            case "later": return Color(red: 1.0, green: 0.6, blue: 0.0) // Orange
            case "done": return Color(red: 1.0, green: 0.7, blue: 0.7) // Pastel red for urgency
            default: return .gray
            }
        case .school:
            switch id {
            case "today": return self.modeButtonColor // Purple for SCHOOL mode
            case "thisWeek": return Color(red: 0.478, green: 0.686, blue: 0.961) // #7aaff5
            case "later": return Color(red: 1.0, green: 0.6, blue: 0.0) // Orange
            case "done": return Color(red: 1.0, green: 0.7, blue: 0.7) // Pastel red for urgency
            default: return .gray
            }
        }
    }
    
    func getSecondPageButtons() -> [(title: String, color: Color)] {
        switch self {
        case .life:
            return [
                ("MODES", Color(red: 0.702, green: 0.804, blue: 0.702)),
                ("ONE", Color(red: 0.702, green: 0.784, blue: 0.961)),
                ("TWO", Color(red: 0.804, green: 0.702, blue: 0.961)),
                ("SETTINGS", Color(red: 0.961, green: 0.702, blue: 0.702))
            ]
        case .work:
            return [
                ("MODES", Color(red: 0.8, green: 0.9, blue: 1.0)),
                ("ONE", Color(red: 1.0, green: 0.9, blue: 0.8)),
                ("TWO", Color(red: 0.9, green: 1.0, blue: 0.8)),
                ("SETTINGS", Color(red: 1.0, green: 0.8, blue: 0.8))
            ]
        case .school:
            return [
                ("MODES", Color(red: 0.9, green: 0.8, blue: 1.0)),
                ("ONE", Color(red: 0.8, green: 1.0, blue: 0.9)),
                ("TWO", Color(red: 1.0, green: 1.0, blue: 0.8)),
                ("SETTINGS", Color(red: 1.0, green: 0.8, blue: 0.9))
            ]
        }
    }
}

extension Color {
    struct RGBValues: Codable {
        let red: Double
        let green: Double
        let blue: Double
    }
    
    init(rgbValues: RGBValues) {
        self.init(red: rgbValues.red, green: rgbValues.green, blue: rgbValues.blue)
    }
}

class TaskStore: ObservableObject {
    // Speech synthesizer for notifications
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    func speakNotification(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.rate = 0.5
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(utterance)
    }
    @Published var tasks: [Task] = [] {
        didSet { saveTasks() }
    }
    
    @Published var lists: [TaskList] = [] {
        didSet { saveLists() }
    }
    
    @Published var currentListId: String = "menu"
    @Published var currentMode: ViewMode = .life {
        didSet {
            UserDefaults.standard.set(currentMode.rawValue, forKey: "currentViewMode")
            updateListsForMode()
        }
    }
    @Published var selectedCalendarDate: Date? = nil
    @Published var calendarDisplayDate: Date = Date()
    @Published var longPressedDate: Date? = nil
    @Published var repeatTaskText: String = ""
    @Published var selectedTemplate: String? = nil
    @Published var taskToEdit: Task? = nil
    
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "todomaiTasks"
    private let listsKey = "todomaiLists"
    
    init() {
        // Load saved mode IMMEDIATELY to prevent flash
        if let savedMode = userDefaults.string(forKey: "currentViewMode"),
           let mode = ViewMode(rawValue: savedMode) {
            currentMode = mode
        }
        
        // Ensure no task is being edited on startup
        taskToEdit = nil
        
        // Minimal initialization for faster startup
        updateListsForMode() // Set up lists immediately
        
        // TEMPORARY: Force clear all test data
        userDefaults.removeObject(forKey: tasksKey)
        userDefaults.synchronize()
        
        // Add a repeat task for July 16th
        var july16Task = Task(
            text: "Weekly Team Meeting",
            listId: "calendar_2025-07-16_recurring",
            mode: "life"
        )
        july16Task.dueDate = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 16))
        july16Task.isRecurring = true
        tasks.append(july16Task)
        
        // Add a repeat task for today (July 20th)
        var todayTask = Task(
            text: "Daily Standup Every Sunday",
            listId: "calendar_2025-07-20_recurring",
            mode: "life"
        )
        todayTask.dueDate = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 20, hour: 9, minute: 30))
        todayTask.isRecurring = true
        todayTask.hasReminder = true
        todayTask.reminderMinutesBefore = 30
        tasks.append(todayTask)
        
        // Add a school task for July 16th
        var schoolTask = Task(
            text: "Physics Lab Report Due",
            listId: "calendar_2025-07-16",
            mode: "school"
        )
        schoolTask.dueDate = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 16, hour: 14, minute: 0))
        schoolTask.hasReminder = true
        schoolTask.reminderMinutesBefore = 120 // 2 hours before
        tasks.append(schoolTask)
        
        // Defer heavy operations
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Load saved tasks in production mode
            self.loadTasks()
            
            // Filter out any tasks with [TEST] in them
            self.tasks = self.tasks.filter { task in
                !task.text.contains("[TEST]")
            }
            
            // Save the cleaned tasks
            if !self.tasks.isEmpty {
                self.saveTasks()
            }
        }
    }
    
    private func updateListsForMode() {
        let listIds = currentMode.getListIds()
        lists = listIds.map { id in
            let name = currentMode.getListName(for: id)
            // Color is determined by id in the switch below
            
            // Convert SwiftUI Color to RGB values - use the mode's color logic
            let color = currentMode.getListColor(for: id)
            
            // Convert SwiftUI Color to RGB values
            let rgbValues: Color.RGBValues
            if color == .blue {
                rgbValues = Color.RGBValues(red: 0.0, green: 0.478, blue: 1.0)
            } else if color == .red {
                rgbValues = Color.RGBValues(red: 1.0, green: 0.0, blue: 0.0)
            } else if color == .green {
                rgbValues = Color.RGBValues(red: 0.0, green: 0.8, blue: 0.0)
            } else if color == .orange {
                rgbValues = Color.RGBValues(red: 1.0, green: 0.6, blue: 0.0)
            } else if color == .purple {
                rgbValues = Color.RGBValues(red: 0.6, green: 0.0, blue: 1.0)
            } else if color == .white {
                rgbValues = Color.RGBValues(red: 1.0, green: 1.0, blue: 1.0)
            } else if color == Color(red: 0.859, green: 0.835, blue: 0.145) {
                rgbValues = Color.RGBValues(red: 0.859, green: 0.835, blue: 0.145) // Yellow
            } else {
                // Extract RGB from the color - this handles custom colors
                rgbValues = Color.RGBValues(red: 0.5, green: 0.5, blue: 0.5) // Gray fallback
            }
            
            return TaskList(id: id, name: name, color: rgbValues)
        }
    }
    
    var currentList: TaskList? {
        lists.first { $0.id == currentListId }
    }
    
    var currentTasks: [Task] {
        tasks.filter { $0.listId == currentListId && $0.mode == currentMode.rawValue && !$0.isCompleted }
    }
    
    var completedTasks: [Task] {
        tasks.filter { $0.listId == currentListId && $0.mode == currentMode.rawValue && $0.isCompleted }
    }
    
    func processVoiceInput(_ text: String) {
        let lowercased = text.lowercased()
        let validListIds = currentMode.getListIds()
        
        // Smart parsing for list detection based on current mode
        if lowercased.contains("today") && validListIds.contains("today") {
            currentListId = "today"
            addTask(cleanTaskText(text, listName: "today"))
        } else if currentMode == .life && (lowercased.contains("later") || lowercased.contains("someday")) {
            currentListId = "later"
            addTask(cleanTaskText(text, listName: "someday"))
        } else if currentMode == .life && lowercased.contains("done") {
            currentListId = "done"
            addTask(cleanTaskText(text, listName: "done"))
        } else if currentMode == .work && lowercased.contains("week") {
            currentListId = "week"
            addTask(cleanTaskText(text, listName: "week"))
        } else if currentMode == .work && lowercased.contains("month") {
            currentListId = "month"
            addTask(cleanTaskText(text, listName: "month"))
        } else if currentMode == .school && lowercased.contains("assignments") {
            currentListId = "assignments"
            addTask(cleanTaskText(text, listName: "assignments"))
        } else if currentMode == .school && lowercased.contains("exams") {
            currentListId = "exams"
            addTask(cleanTaskText(text, listName: "exams"))
        } else {
            // Add to current list
            addTask(text)
        }
    }
    
    private func cleanTaskText(_ text: String, listName: String) -> String {
        var cleaned = text
        let phrasesToRemove = [
            "add ", "to \(listName)", "to my \(listName) list", 
            "to the \(listName) list", "to \(listName) list"
        ]
        
        for phrase in phrasesToRemove {
            cleaned = cleaned.replacingOccurrences(of: phrase, with: "", options: .caseInsensitive)
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func addTask(_ text: String) {
        var taskText = text
        var dueDate: Date? = nil
        
        // Parse time from text
        let timePatterns = [
            // Match "at 3:30", "at 3:30pm", "at 15:30"
            #"at\s+(\d{1,2}):(\d{2})\s*(am|pm)?"#,
            // Match "3:30pm", "15:30", "3:30 pm" - must be word boundary to avoid matching in middle
            #"\b(\d{1,2}):(\d{2})\s*(am|pm)?"#,
            // Match "at 3pm", "at 3 pm"
            #"at\s+(\d{1,2})\s*(am|pm)"#,
            // Match "3pm", "3 pm"
            #"\b(\d{1,2})\s*(am|pm)"#
        ]
        
        for pattern in timePatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let nsString = text as NSString
                if let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: nsString.length)) {
                    // Remove the time part from the task text
                    taskText = nsString.replacingCharacters(in: match.range, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Parse the time
                    let calendar = Calendar.current
                    var components = calendar.dateComponents([.year, .month, .day], from: Date())
                    
                    if match.numberOfRanges >= 3 {
                        // Has hour and minute
                        if let hourRange = Range(match.range(at: 1), in: text),
                           let hour = Int(text[hourRange]) {
                            components.hour = hour
                            
                            if match.numberOfRanges >= 3,
                               let minuteRange = Range(match.range(at: 2), in: text),
                               let minute = Int(text[minuteRange]) {
                                components.minute = minute
                            } else {
                                components.minute = 0
                            }
                            
                            // Check for AM/PM
                            if match.numberOfRanges >= 4 {
                                let lastGroup = match.numberOfRanges - 1
                                if let ampmRange = Range(match.range(at: lastGroup), in: text) {
                                    let ampm = text[ampmRange].lowercased()
                                    if ampm == "pm" && components.hour! < 12 {
                                        components.hour! += 12
                                    } else if ampm == "am" && components.hour! == 12 {
                                        components.hour = 0
                                    }
                                }
                            }
                        }
                    } else if match.numberOfRanges >= 2 {
                        // Just hour with AM/PM
                        if let hourRange = Range(match.range(at: 1), in: text),
                           let hour = Int(text[hourRange]) {
                            components.hour = hour
                            components.minute = 0
                            
                            if let ampmRange = Range(match.range(at: 2), in: text) {
                                let ampm = text[ampmRange].lowercased()
                                if ampm == "pm" && hour < 12 {
                                    components.hour! += 12
                                } else if ampm == "am" && hour == 12 {
                                    components.hour = 0
                                }
                            }
                        }
                    }
                    
                    dueDate = calendar.date(from: components)
                    break
                }
            }
        }
        
        var task = Task(text: taskText, listId: currentListId, mode: currentMode.rawValue)
        
        // If no specific time was parsed but task is for "today", set due date to today
        if dueDate == nil && currentListId == "today" {
            dueDate = Date()
        }
        
        task.dueDate = dueDate
        tasks.insert(task, at: 0)
    }
    
    func addList(_ name: String) {
        let colors: [Color.RGBValues] = [
            Color.RGBValues(red: 1.0, green: 0.95, blue: 0.95),
            Color.RGBValues(red: 0.95, green: 0.95, blue: 1.0),
            Color.RGBValues(red: 0.95, green: 1.0, blue: 0.95),
            Color.RGBValues(red: 1.0, green: 1.0, blue: 0.95),
            Color.RGBValues(red: 1.0, green: 0.95, blue: 1.0),
            Color.RGBValues(red: 0.95, green: 1.0, blue: 1.0)
        ]
        
        let colorIndex = lists.count % colors.count
        let newList = TaskList(id: UUID().uuidString, name: name, color: colors[colorIndex])
        lists.append(newList)
    }
    
    func deleteTask(at offsets: IndexSet) {
        let tasksToDelete = offsets.map { currentTasks[$0] }
        tasks.removeAll { task in
            tasksToDelete.contains { $0.id == task.id }
        }
    }
    
    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
            if tasks[index].isCompleted {
                // Say "Task completed" using text-to-speech
                let utterance = AVSpeechUtterance(string: "Task completed")
                utterance.rate = 0.5
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterance)
            }
        }
    }
    
    func clearCompleted() {
        tasks.removeAll { $0.isCompleted && $0.listId == currentListId }
    }
    
    func moveTaskToToday(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].listId = "today"
        }
    }
    
    func cycleThroughModes() {
        let allModes = ViewMode.allCases
        if let currentIndex = allModes.firstIndex(of: currentMode) {
            let nextIndex = (currentIndex + 1) % allModes.count
            currentMode = allModes[nextIndex]
        }
    }
    
    func navigateToNextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: calendarDisplayDate) {
            calendarDisplayDate = newDate
        }
    }
    
    func navigateToPreviousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: calendarDisplayDate) {
            calendarDisplayDate = newDate
        }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: tasksKey)
        }
    }
    
    private func saveLists() {
        if let encoded = try? JSONEncoder().encode(lists) {
            userDefaults.set(encoded, forKey: listsKey)
        }
    }
    
    private func loadTasks() {
        if let data = userDefaults.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
    
    private func loadData() {
        loadTasks()
        
        if let data = userDefaults.data(forKey: listsKey),
           let decoded = try? JSONDecoder().decode([TaskList].self, from: data) {
            lists = decoded
        }
    }
    
    func removeTestPrefixes() {
        // Remove [TEST] prefix from all task names
        var tasksUpdated = false
        for i in 0..<tasks.count {
            if tasks[i].text.hasPrefix("[TEST] ") {
                tasks[i].text = String(tasks[i].text.dropFirst(7))
                tasksUpdated = true
            }
        }
        // Save the cleaned tasks if any were updated
        if tasksUpdated {
            saveTasks()
        }
    }
    
    func clearAllTestData() {
        // Clear all tasks that have [TEST] in their text
        tasks = tasks.filter { !$0.text.contains("[TEST]") }
        // Also remove the prefix from remaining tasks
        removeTestPrefixes()
        saveTasks()
    }
}