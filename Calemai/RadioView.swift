//
//  RadioView.swift
//  Todomai-iOS
//
//  Radio stations grid view with beautiful custom design
//

import SwiftUI

// MARK: - Radio View
struct RadioView: View {
    @ObservedObject var taskStore: TaskStore
    @Binding var currentTab: String
    @StateObject private var downloadManager = StationDownloadManager.shared
    @State private var selectedStation: MusicStation? = nil
    @State private var showingStationDetail = false
    @State private var showingMusicPlayer = false
    
    let stations = [
        StationDownloadManager.shared.lofiStation,
        StationDownloadManager.shared.getStation(by: "piano"),
        StationDownloadManager.shared.getStation(by: "hiphop"),
        StationDownloadManager.shared.getStation(by: "jungle")
    ]
    
    var backgroundColor: Color {
        Color(red: 0.4, green: 0.9, blue: 0.6) // Radio green
    }
    
    var body: some View {
        mainContent
            .sheet(isPresented: $showingStationDetail) {
                stationDetailSheet
            }
            .fullScreenCover(isPresented: $showingMusicPlayer) {
                musicPlayerSheet
            }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(spacing: 24) {
                        titleView
                        stationsGridView
                        descriptionView
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                currentTab = "menu"
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(.white)
                    Text("BACK")
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Text("RADIO")
                .font(.system(size: 17, weight: .heavy))
                .foregroundColor(.white)
            
            Spacer()
            
            // Invisible spacer to balance the header
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(.clear)
                Text("BACK")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundColor(.clear)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .padding(.bottom, 20)
    }
    
    private var titleView: some View {
        Text("SELECT A STATION")
            .font(.system(size: 28, weight: .heavy))
            .foregroundColor(.white)
            .padding(.top, 20)
    }
    
    private var stationsGridView: some View {
        HStack(spacing: 16) {
            Spacer()
            LazyVGrid(columns: [
                GridItem(.fixed(140), spacing: 16),
                GridItem(.fixed(140), spacing: 16)
            ], spacing: 16) {
                ForEach(stations, id: \.id) { station in
                    StationCard(
                        station: station,
                        downloadState: downloadManager.downloadStates[station.id] ?? .notDownloaded,
                        action: {
                            selectedStation = station
                            
                            // If downloaded, show player; otherwise show detail
                            if downloadManager.downloadStates[station.id] == .downloaded {
                                showingMusicPlayer = true
                            } else {
                                showingStationDetail = true
                            }
                        }
                    )
                }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
    }
    
    private var descriptionView: some View {
        VStack(spacing: 16) {
            Text("TAP A STATION TO LISTEN")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            
            Text("DOWNLOAD STATIONS FOR OFFLINE LISTENING")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.top, 40)
    }
    
    @ViewBuilder
    private var stationDetailSheet: some View {
        if let station = selectedStation {
            StationDetailView(
                station: station,
                downloadManager: downloadManager,
                onClose: {
                    showingStationDetail = false
                    selectedStation = nil
                }
            )
        }
    }
    
    @ViewBuilder
    private var musicPlayerSheet: some View {
        if let station = selectedStation {
            MusicPlayerView(
                station: station,
                downloadManager: downloadManager,
                onClose: {
                    showingMusicPlayer = false
                    selectedStation = nil
                }
            )
        }
    }
}

// MARK: - Station Card Component
struct StationCard: View {
    let station: MusicStation
    let downloadState: StationDownloadState
    let action: () -> Void
    
    var statusIcon: String {
        switch downloadState {
        case .downloaded:
            return "play.circle.fill"
        case .downloading:
            return "arrow.down.circle.fill"
        default:
            return station.isAvailable ? "arrow.down.circle" : "lock.circle"
        }
    }
    
    var body: some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            action()
        }) {
            VStack(spacing: 0) {
                // Station icon placeholder
                ZStack {
                    Rectangle()
                        .fill(station.color)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "music.note")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundColor(.white)
                        
                        // Download status indicator
                        if case .downloading(let progress) = downloadState {
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .tint(.white)
                                .frame(width: 60)
                                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                        } else {
                            Image(systemName: statusIcon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                
                // Station info
                VStack(spacing: 2) {
                    Text(station.name)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundColor(.white)
                    
                    if station.isAvailable {
                        Text("\(station.songCount) songs")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text("COMING SOON")
                            .font(.system(size: 9, weight: .heavy))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    station.color
                        .overlay(Color.black.opacity(0.2))
                )
            }
            .background(station.color)
            .overlay(
                Rectangle()
                    .stroke(Color.black, lineWidth: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Station Detail View
struct StationDetailView: View {
    let station: MusicStation
    @ObservedObject var downloadManager: StationDownloadManager
    let onClose: () -> Void
    @State private var shouldShowPlayer = false
    
    var downloadState: StationDownloadState {
        downloadManager.downloadStates[station.id] ?? .notDownloaded
    }
    
    var body: some View {
        ZStack {
            station.color.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        onClose()
                    }) {
                        Text("CLOSE")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    if case .downloaded = downloadState {
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            downloadManager.deleteStation(station.id)
                        }) {
                            Text("DELETE")
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Station icon
                        VStack(spacing: 16) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 160, height: 160)
                                
                                Image(systemName: "music.note")
                                    .font(.system(size: 80, weight: .heavy))
                                    .foregroundColor(.white)
                            }
                            .overlay(
                                Rectangle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            
                            Text(station.name)
                                .font(.system(size: 36, weight: .heavy))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 40)
                        
                        if station.isAvailable {
                            // Station info
                            VStack(spacing: 20) {
                                HStack(spacing: 40) {
                                    VStack(spacing: 4) {
                                        Text("\(station.songCount)")
                                            .font(.system(size: 32, weight: .heavy))
                                            .foregroundColor(.white)
                                        Text("SONGS")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text("~\(station.totalSizeMB)")
                                            .font(.system(size: 32, weight: .heavy))
                                            .foregroundColor(.white)
                                        Text("MB")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                                
                                // Download button/status
                                Group {
                                    switch downloadState {
                                    case .notDownloaded:
                                        Button(action: {
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                            impactFeedback.impactOccurred()
                                            downloadManager.downloadStation(station)
                                        }) {
                                            HStack(spacing: 12) {
                                                Image(systemName: "arrow.down.circle.fill")
                                                    .font(.system(size: 24))
                                                Text("DOWNLOAD STATION")
                                                    .font(.system(size: 18, weight: .heavy))
                                            }
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 64)
                                            .background(Color.white)
                                            .overlay(
                                                Rectangle()
                                                    .stroke(Color.black, lineWidth: 4)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                    case .downloading(let progress):
                                        VStack(spacing: 16) {
                                            Text("DOWNLOADING...")
                                                .font(.system(size: 18, weight: .heavy))
                                                .foregroundColor(.white)
                                            
                                            StationDownloadProgressView(progress: progress)
                                                .frame(height: 40)
                                            
                                            Button(action: {
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                                impactFeedback.impactOccurred()
                                                downloadManager.cancelDownload()
                                            }) {
                                                Text("CANCEL")
                                                    .font(.system(size: 16, weight: .heavy))
                                                    .foregroundColor(.white.opacity(0.7))
                                            }
                                        }
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white.opacity(0.1))
                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.white, lineWidth: 3)
                                        )
                                        
                                    case .downloaded:
                                        VStack(spacing: 16) {
                                            Button(action: {
                                                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                                                impactFeedback.impactOccurred()
                                                shouldShowPlayer = true
                                            }) {
                                                HStack(spacing: 12) {
                                                    Image(systemName: "play.circle.fill")
                                                        .font(.system(size: 28))
                                                    Text("PLAY STATION")
                                                        .font(.system(size: 20, weight: .heavy))
                                                }
                                                .foregroundColor(.black)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 72)
                                                .background(Color.white)
                                                .overlay(
                                                    Rectangle()
                                                        .stroke(Color.black, lineWidth: 4)
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            
                                            HStack(spacing: 12) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.green)
                                                Text("DOWNLOADED")
                                                    .font(.system(size: 14, weight: .heavy))
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                        }
                                        
                                    case .error(let message):
                                        VStack(spacing: 8) {
                                            Text("ERROR")
                                                .font(.system(size: 16, weight: .heavy))
                                                .foregroundColor(.red)
                                            Text(message)
                                                .font(.system(size: 14))
                                                .foregroundColor(.white.opacity(0.7))
                                                .multilineTextAlignment(.center)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red.opacity(0.2))
                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.red, lineWidth: 3)
                                        )
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        } else {
                            // Coming soon message
                            VStack(spacing: 16) {
                                Text("COMING SOON")
                                    .font(.system(size: 24, weight: .heavy))
                                    .foregroundColor(.white)
                                
                                Text("This station will be available in a future update")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.7))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.vertical, 40)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .fullScreenCover(isPresented: $shouldShowPlayer) {
            MusicPlayerView(
                station: station,
                downloadManager: downloadManager,
                onClose: {
                    shouldShowPlayer = false
                }
            )
        }
    }
}

#Preview {
    RadioView(taskStore: TaskStore(), currentTab: .constant("radio"))
}