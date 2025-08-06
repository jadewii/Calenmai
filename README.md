# Todomai - watchOS Todo App

A minimal watchOS app for managing tasks with voice input.

## Setup Instructions

1. Open Xcode
2. Create a new project:
   - Choose "watchOS" > "App"
   - Product Name: Todomai
   - Interface: SwiftUI
   - Language: Swift
   - Include Notification Scene: No

3. Replace the generated files:
   - Delete the default `ContentView.swift` and `TodomaiApp.swift`
   - Copy the files from this directory:
     - `Todomai WatchKit App/TodomaiApp.swift`
     - `Todomai WatchKit App/ContentView.swift`
     - Update Info.plist settings

4. Build and run on Apple Watch simulator or device

## Features

- Voice input for adding tasks
- Task completion tracking
- Persistent storage using UserDefaults
- Clear completed tasks
- Time stamps for each task
- Suggested phrases for quick input

## Usage

1. Tap the microphone button to add a new task
2. Speak your task or select from suggestions
3. Tap the circle to mark tasks as complete
4. Swipe left to delete individual tasks
5. Use "Clear Completed" to remove all finished tasks