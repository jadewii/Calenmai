import SwiftUI

@main
struct TodomaiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct Task: Identifiable, Codable {
    let id = UUID()
    var text: String
    var isCompleted: Bool = false
    var createdAt = Date()
}

class TaskStore: ObservableObject {
    @Published var tasks: [Task] = [] {
        didSet {
            saveTasks()
        }
    }
    
    private let userDefaults = UserDefaults.standard
    private let tasksKey = "todomaiTasks"
    
    init() {
        loadTasks()
    }
    
    func addTask(_ text: String) {
        let task = Task(text: text)
        tasks.insert(task, at: 0)
    }
    
    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
    
    func toggleTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
    
    func clearCompleted() {
        tasks.removeAll { $0.isCompleted }
    }
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            userDefaults.set(encoded, forKey: tasksKey)
        }
    }
    
    private func loadTasks() {
        if let data = userDefaults.data(forKey: tasksKey),
           let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        }
    }
}