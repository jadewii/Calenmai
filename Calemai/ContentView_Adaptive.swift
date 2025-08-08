//
//  ContentView_Adaptive.swift
//  Calemai
//
//  Adaptive ContentView that works on iPhone, iPad, and macOS
//

import SwiftUI

struct ContentView_Adaptive: View {
    @StateObject private var taskStore = TaskStore()
    @State private var currentTab = "calendar"
    @State private var isRouletteMode = false
    @State private var showRandomModeSelection = false
    @State private var isInYearMode = false
    @State private var selectedPriorityTask: Task? = nil
    @State private var showTimerSelection = false
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic
    
    
    var body: some View {
        Group {
            #if os(iOS)
            if UIDevice.current.userInterfaceIdiom == .pad {
                // iPad layout with split view
                iPadLayout
            } else {
                // iPhone layout
                iPhoneLayout
            }
            #elseif os(macOS)
            // macOS layout uses same as iPad
            iPadLayout
            #else
            // Fallback to iPhone layout
            iPhoneLayout
            #endif
        }
    }
    
    // MARK: - iPhone Layout (current implementation)
    private var iPhoneLayout: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.ignoresSafeArea()
                
                // Main navigation switch - exactly like watchOS
                switch currentTab {
                case "menu":
                    MenuView(
                        taskStore: taskStore,
                        currentTab: $currentTab,
                        isRouletteMode: $isRouletteMode,
                        showRandomModeSelection: $showRandomModeSelection
                    )
                    
                case "today":
                    TodayView(taskStore: taskStore, currentTab: $currentTab)
                    
                case "thisWeek":
                    ThisWeekView(taskStore: taskStore, currentTab: $currentTab)
                    
                case "calendar":
                    CalendarView()
                        .environmentObject(taskStore)
                    
                case "dayView":
                    DayView(taskStore: taskStore, currentTab: $currentTab)
                    
                case "getItDone":
                    GetItDoneView(
                        taskStore: taskStore,
                        currentTab: $currentTab,
                        selectedPriorityTask: $selectedPriorityTask,
                        showTimerSelection: $showTimerSelection,
                        isRouletteMode: $isRouletteMode
                    )
                    
                case "routines":
                    RoutinesView(
                        taskStore: taskStore,
                        currentTab: $currentTab
                    )
                    
                case "radio":
                    RadioView(
                        taskStore: taskStore,
                        currentTab: $currentTab
                    )
                    
                case "getItDone":
                    GetItDoneView(
                        taskStore: taskStore,
                        currentTab: $currentTab,
                        selectedPriorityTask: $selectedPriorityTask,
                        showTimerSelection: $showTimerSelection,
                        isRouletteMode: $isRouletteMode
                    )
                    
                default:
                    // Check if it's a list view
                    if ["later", "appointments", "settings"].contains(currentTab) {
                        ListsView(
                            taskStore: taskStore,
                            currentTab: $currentTab,
                            isProcessing: .constant(false),
                            listId: currentTab,
                            listName: getListName(for: currentTab),
                            backgroundColor: getListColor(for: currentTab)
                        )
                    } else {
                        MenuView(
                            taskStore: taskStore,
                            currentTab: $currentTab,
                            isRouletteMode: $isRouletteMode,
                            showRandomModeSelection: $showRandomModeSelection
                        )
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    handleSwipeGesture(value: value)
                }
        )
    }
    
    // MARK: - iPad Layout with custom UI
    private var iPadLayout: some View {
        ZStack {
            // Background color for entire screen
            Group {
                switch currentTab {
                case "today":
                    Color.white
                case "thisWeek":
                    Color(red: 0.478, green: 0.686, blue: 0.961)
                case "routines":
                    Color(red: 0.8, green: 0.8, blue: 1.0)
                case "appointments":
                    Color(red: 0.8, green: 0.6, blue: 1.0)
                case "radio":
                    Color(red: 0.4, green: 0.9, blue: 0.6)
                case "getItDone":
                    Color.red
                case "settings":
                    Color(red: 0.6, green: 0.6, blue: 0.6)
                case "calendar":
                    Color.purple.opacity(0.1)
                case "later":
                    Color(red: 0.859, green: 0.835, blue: 0.145)
                case "week", "month", "assignments", "exams",
                     "routine", "goals", "plans", "bills",
                     "projects", "schedule", "ideas", "deadlines",
                     "homework", "study", "notes", "tests":
                    getListColor(for: currentTab)
                default:
                    Color.white
                }
            }
            .ignoresSafeArea()
            
            HStack(spacing: 0) {
                // Custom sidebar
                CalemaiSidebar(taskStore: taskStore, currentTab: $currentTab)
                    .frame(width: 320)
                
                // Detail view - each view controls its own background
                Group {
                    switch currentTab {
                    case "today":
                        TodayView(taskStore: taskStore, currentTab: $currentTab)
                    case "thisWeek":
                        ThisWeekView(taskStore: taskStore, currentTab: $currentTab)
                    case "calendar":
                        CalendarView()
                            .environmentObject(taskStore)
                    case "dayView":
                        DayView(taskStore: taskStore, currentTab: $currentTab)
                    case "setRepeatTask":
                        SetRepeatTaskView(taskStore: taskStore, currentTab: $currentTab)
                    case "editTask":
                        EditTaskView(taskStore: taskStore, currentTab: $currentTab)
                    case "repeatFrequency":
                        RepeatFrequencyView(taskStore: taskStore, currentTab: $currentTab)
                    case "settings":
                        SettingsView(taskStore: taskStore, currentTab: $currentTab)
                    case "routines":
                        RoutinesView(
                            taskStore: taskStore,
                            currentTab: $currentTab
                        )
                    case "radio":
                        RadioView(
                            taskStore: taskStore,
                            currentTab: $currentTab
                        )
                    case "getItDone":
                        GetItDoneView(
                            taskStore: taskStore,
                            currentTab: $currentTab,
                            selectedPriorityTask: $selectedPriorityTask,
                            showTimerSelection: $showTimerSelection,
                            isRouletteMode: $isRouletteMode
                        )
                    case "later", "week", "month", "assignments", "exams",
                         "routine", "goals", "plans", "bills",
                         "projects", "schedule", "ideas", "deadlines",
                         "homework", "study", "notes", "tests",
                         "appointments":
                        ListsView(
                            taskStore: taskStore,
                            currentTab: $currentTab,
                            isProcessing: .constant(false),
                            listId: currentTab,
                            listName: getListName(for: currentTab),
                            backgroundColor: getListColor(for: currentTab)
                        )
                    default:
                        // Default view or empty state
                        ZStack {
                            Color.white.ignoresSafeArea()
                            VStack {
                                Spacer()
                                Text("SELECT A VIEW")
                                    .font(.system(size: 48, weight: .heavy))
                                    .foregroundColor(.black.opacity(0.2))
                                Spacer()
                            }
                        }
                    }
                }
                .id(currentTab) // Force view refresh on tab change
                .animation(nil, value: currentTab) // Remove animation on tab change
            } // End HStack
        } // End ZStack
    }
    
    // MARK: - Helper Methods
    private func detailView(for tab: String) -> some View {
        Group {
            switch tab {
            case "today":
                TodayView(taskStore: taskStore, currentTab: $currentTab)
            case "thisWeek":
                ThisWeekView(taskStore: taskStore, currentTab: $currentTab)
            case "calendar":
                CalendarView()
                    .environmentObject(taskStore)
            case "dayView":
                DayView(taskStore: taskStore, currentTab: $currentTab)
            case "setRepeatTask":
                SetRepeatTaskView(taskStore: taskStore, currentTab: $currentTab)
            case "editTask":
                EditTaskView(taskStore: taskStore, currentTab: $currentTab)
            case "repeatFrequency":
                RepeatFrequencyView(taskStore: taskStore, currentTab: $currentTab)
            case "later", "week", "month", "assignments", "exams",
                 "routine", "goals", "plans", "bills",
                 "projects", "schedule", "ideas", "deadlines",
                 "homework", "study", "notes", "tests",
                 "routines", "appointments":
                ListsView(
                    taskStore: taskStore,
                    currentTab: $currentTab,
                    isProcessing: .constant(false),
                    listId: currentTab,
                    listName: getListName(for: currentTab),
                    backgroundColor: getListColor(for: currentTab)
                )
            default:
                EmptyStateView()
            }
        }
    }
    
    private func handleSwipeGesture(value: DragGesture.Value) {
        // Simple swipe detection - matches watchOS logic
        if currentTab == "menu" {
            if value.translation.width < -50 {
                currentTab = "getItDone"
            }
        } else if currentTab == "calendar" {
            // Calendar handles its own swipes for month navigation
            // Don't navigate away from calendar on swipe
        }
    }
    
    func getListName(for id: String) -> String {
        switch id {
        case "routine": return "ROUTINE"
        case "goals": return "GOALS"
        case "plans": return "PLANS"
        case "bills": return "BILLS"
        case "projects": return "PROJECTS"
        case "schedule": return "SCHEDULE"
        case "ideas": return "IDEAS"
        case "deadlines": return "DEADLINES"
        case "homework": return "HOMEWORK"
        case "study": return "STUDY"
        case "notes": return "NOTES"
        case "tests": return "TESTS"
        case "routines": return "ROUTINES"
        case "appointments": return "APPOINTMENTS"
        case "radio": return "RADIO"
        case "settings": return "SETTINGS"
        default: return taskStore.currentMode.getListName(for: id)
        }
    }
    
    func getListColor(for id: String) -> Color {
        switch id {
        case "routine": return Color(red: 0.4, green: 0.8, blue: 0.4)
        case "goals": return Color(red: 1.0, green: 0.6, blue: 0.8)
        case "plans": return Color(red: 0.8, green: 0.6, blue: 1.0)
        case "bills": return Color(red: 1.0, green: 0.7, blue: 0.3)
        case "projects": return Color(red: 0.4, green: 0.6, blue: 1.0)
        case "schedule": return Color(red: 0.4, green: 0.8, blue: 0.4)
        case "ideas": return Color(red: 1.0, green: 0.9, blue: 0.4)
        case "deadlines": return Color(red: 1.0, green: 0.4, blue: 0.4)
        case "homework": return Color(red: 0.8, green: 0.6, blue: 1.0)
        case "study": return Color(red: 0.6, green: 0.8, blue: 1.0)
        case "notes": return Color(red: 1.0, green: 0.9, blue: 0.4)
        case "tests": return Color(red: 1.0, green: 0.4, blue: 0.4)
        case "routines": return Color(red: 0.8, green: 0.8, blue: 1.0)
        case "appointments": return Color(red: 0.8, green: 0.6, blue: 1.0)
        case "radio": return Color(red: 0.4, green: 0.9, blue: 0.6)
        case "settings": return Color(red: 0.6, green: 0.6, blue: 0.6)
        default: return taskStore.currentMode.getListColor(for: id)
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "checkmark.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.3))
            Text("Select an item from the sidebar")
                .font(.title)
                .foregroundColor(.gray)
            Spacer()
        }
    }
}

#Preview {
    ContentView_Adaptive()
}