//
//  ContentView.swift
//  Movie Remote
//
//  Created by Khant Linn on 21/10/2026.
//

import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @State private var isPlaying: Bool = true
    @StateObject private var peer = PeerSession()

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(colors: [Color(.systemBackground), Color.accentColor.opacity(0.15)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                header
                Spacer(minLength: 0)
                controls
                Spacer(minLength: 0)
                footer
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            Image(systemName: "bolt.horizontal.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(peer.isConnected ? .green : .orange, .secondary)
                .font(.system(size: 28, weight: .bold))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Movie Remote")
                    .font(.title2.bold())
                HStack(spacing: 6) {
                    Image(systemName: peer.isConnected ? "dot.radiowaves.left.and.right" : "wifi.slash")
                        .font(.footnote)
                        .foregroundStyle(peer.isConnected ? .green : .secondary)
                    Text(peer.isConnected ? "Connected to \(peer.connectedPeerName ?? "Mac")" : "Not connected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button(action: connectOrDisconnect) {
                Label(peer.isConnected ? "Disconnect" : "Connect", systemImage: peer.isConnected ? "xmark.circle.fill" : "wave.3.right.circle.fill")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 24, weight: .semibold))
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(peer.isConnected ? "Disconnect" : "Connect")
            .tint(peer.isConnected ? .red : .accentColor)
        }
    }

    private var controls: some View {
        VStack(spacing: 28) {
            // Transport controls
            HStack(spacing: 36) {
                roundButton(systemName: "backward.fill", size: 56, prominent: false, action: sendBackward)
                playPauseButton
                roundButton(systemName: "forward.fill", size: 56, prominent: false, action: sendForward)
            }

            // Volume controls with labels
            HStack(spacing: 20) {
                pillButton(title: "Volume -", systemImage: "speaker.wave.1.fill", action: volumeDown)
                pillButton(title: "Volume +", systemImage: "speaker.wave.3.fill", action: volumeUp)
            }
        }
    }

    private var playPauseButton: some View {
        Button(action: togglePlayPause) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.gradient)
                    .frame(width: 96, height: 96)
                    .shadow(color: Color.accentColor.opacity(0.35), radius: 20, x: 0, y: 10)
                Image(systemName: "playpause.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isPlaying ? "Pause" : "Play")
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .foregroundStyle(.secondary)
                Text("Bluetooth")
                    .foregroundStyle(.secondary)
                Circle().fill(.secondary).frame(width: 4, height: 4)
                Text(peer.isConnected ? "Ready" : "Tap Connect to pair")
                    .foregroundStyle(peer.isConnected ? .green : .secondary)
            }
            .font(.footnote)

            if !peer.isConnected {
                Text("Make sure your Mac companion app is running and discoverable.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.bottom, 12)
    }

    // MARK: - Styled Buttons

    private func roundButton(systemName: String, size: CGFloat, prominent: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(prominent ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.12))
                    .frame(width: size, height: size)
                Image(systemName: systemName)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
        .overlay(
            Circle().stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }

    private func pillButton(title: String, systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.headline)
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(Capsule().fill(Color.secondary.opacity(0.12)))
        }
        .buttonStyle(.plain)
        .overlay(
            Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }

    // MARK: - Actions

    private func togglePlayPause() {
        isPlaying.toggle()
        sendCommand(.togglePlayPause)
        haptic(.medium)
    }

    private func sendBackward() {
        sendCommand(.backward)
        haptic(.light)
    }

    private func sendForward() {
        sendCommand(.forward)
        haptic(.light)
    }

    private func volumeDown() {
        sendCommand(.volumeDown)
        haptic(.soft)
    }

    private func volumeUp() {
        sendCommand(.volumeUp)
        haptic(.soft)
    }

    private func connectOrDisconnect() {
        if peer.isConnected {
            peer.stop()
        } else {
            peer.start()
        }
        haptic(.rigid)
    }

    private func sendCommand(_ command: RemoteCommand) {
        peer.send(command: command)
    }

    // MARK: - Haptics

    private func haptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}


#Preview {
    ContentView()
}

