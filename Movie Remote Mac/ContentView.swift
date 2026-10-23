
import SwiftUI

struct MacContentView: View {
    @StateObject private var server = PeerServer()
    @State private var isListening = false
    @State private var showActivityLog = false

    private var statusTitle: String {
        if server.isConnected {
            return "Connected"
        }
        return isListening ? "Waiting for iPhone" : "Not Started"
    }

    private var statusDescription: String {
        if server.isConnected {
            return "Your Mac is ready to receive remote commands."
        }
        if isListening {
            return "Open Movie Remote on your iPhone to connect."
        }
        return "Start the companion to accept connections."
    }

    private var statusColor: Color {
        if server.isConnected {
            return .green
        }
        if isListening {
            return .orange
        }
        return .secondary
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider()

            ScrollView {
                VStack(spacing: 20) {
                    connectionCard

                    if showActivityLog {
                        activityLog
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(minWidth: 500, minHeight: 460)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 27, weight: .medium))
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(.blue.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text("Movie Remote")
                    .font(.title2.bold())

                Text("Mac Companion")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                showActivityLog.toggle()
            } label: {
                Label(
                    showActivityLog ? "Hide Log" : "Show Log",
                    systemImage: "list.bullet.rectangle"
                )
            }
            .buttonStyle(.bordered)

            Button {
                toggleServer()
            } label: {
                Label(
                    isListening ? "Stop" : "Start",
                    systemImage: isListening ? "stop.fill" : "play.fill"
                )
            }
            .buttonStyle(.borderedProminent)
            .tint(isListening ? .red : .blue)
            .keyboardShortcut(.defaultAction)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
    }

    // MARK: - Connection

    private var connectionCard: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.12))
                    .frame(width: 76, height: 76)

                Image(systemName: server.isConnected
                      ? "iphone.radiowaves.left.and.right"
                      : "desktopcomputer")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(statusColor)
            }

            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)

                    Text(statusTitle)
                        .font(.title3.bold())
                }

                Text(statusDescription)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if server.isConnected {
                Label(
                    server.connectedPeerName ?? "iPhone",
                    systemImage: "iphone"
                )
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(
                    Color.green.opacity(0.10),
                    in: Capsule()
                )
            } else if isListening {
                ProgressView()
                    .controlSize(.small)
                    .padding(.top, 2)
            }

            Divider()

            HStack(spacing: 24) {
                statusDetail(
                    title: "Connection",
                    value: server.isConnected ? "Active" : (isListening ? "Listening" : "Off"),
                    icon: "point.3.connected.trianglepath.dotted"
                )

                statusDetail(
                    title: "Remote",
                    value: server.isConnected ? "Available" : "Waiting",
                    icon: "iphone.gen3"
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            Color(nsColor: .controlBackgroundColor),
            in: RoundedRectangle(cornerRadius: 18)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(.quaternary, lineWidth: 1)
        }
    }

    private func statusDetail(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        VStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 17))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.weight(.semibold))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Activity Log

    private var activityLog: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Label("Activity Log", systemImage: "terminal")
                    .font(.headline)

                Spacer()

                Text("\(server.log.count) events")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)

            Divider()

            if server.log.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "text.alignleft")
                        .font(.system(size: 24))
                        .foregroundStyle(.tertiary)

                    Text("No activity yet")
                        .font(.subheadline.weight(.medium))

                    Text("Connection events and received commands will appear here.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(
                                Array(server.log.enumerated()),
                                id: \.offset
                            ) { index, line in
                                HStack(alignment: .top, spacing: 10) {
                                    Circle()
                                        .fill(.blue.opacity(0.7))
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 5)

                                    Text(line)
                                        .font(.system(
                                            size: 12,
                                            weight: .regular,
                                            design: .monospaced
                                        ))
                                        .textSelection(.enabled)
                                        .frame(
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        )
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 9)
                                .background {
                                    if index.isMultiple(of: 2) {
                                        Color.primary.opacity(0.025)
                                    }
                                }
                                .id(index)
                            }
                        }
                    }
                    .frame(minHeight: 100, maxHeight: 210)
                    .onChange(of: server.log.count) { _, newCount in
                        if newCount > 0 {
                            withAnimation(.easeOut(duration: 0.2)) {
                                proxy.scrollTo(newCount - 1, anchor: .bottom)
                            }
                        }
                    }
                }
            }
        }
        .background(
            Color(nsColor: .controlBackgroundColor),
            in: RoundedRectangle(cornerRadius: 14)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.quaternary, lineWidth: 1)
        }
    }

    // MARK: - Actions

    private func toggleServer() {
        if isListening {
            server.stop()
            isListening = false
        } else {
            server.start()
            isListening = true
        }
    }
}

#Preview {
    MacContentView()
}

