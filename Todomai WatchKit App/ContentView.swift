import SwiftUI
import WatchKit

struct ContentView: View {
    @StateObject private var taskStore = TaskStore()
    @State private var showingVoiceInput = false
    
    var body: some View {
        NavigationView {
            List {
                Button(action: {
                    presentDictation()
                }) {
                    HStack {
                        Image(systemName: "mic.circle.fill")
                            .font(.title2)
                        Text("Add Task")
                            .font(.headline)
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .listRowBackground(Color.blue.opacity(0.1))
                
                if !taskStore.tasks.isEmpty {
                    Section {
                        ForEach(taskStore.tasks) { task in
                            TaskRow(task: task, taskStore: taskStore)
                        }
                        .onDelete(perform: taskStore.deleteTask)
                    }
                }
                
                if taskStore.tasks.contains(where: { $0.isCompleted }) {
                    Button(action: {
                        taskStore.clearCompleted()
                    }) {
                        Text("Clear Completed")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Todomai")
            .listStyle(CarouselListStyle())
        }
    }
    
    private func presentDictation() {
        WKExtension.shared()
            .visibleInterfaceController?
            .presentTextInputController(
                withSuggestions: ["Buy groceries", "Call mom", "Workout", "Meeting at 3pm"],
                allowedInputMode: .plain
            ) { results in
                if let text = results?.first as? String, !text.isEmpty {
                    taskStore.addTask(text)
                }
            }
    }
}

struct TaskRow: View {
    let task: Task
    let taskStore: TaskStore
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation {
                    taskStore.toggleTask(task)
                }
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.text)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .gray : .primary)
                    .lineLimit(2)
                
                Text(task.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}