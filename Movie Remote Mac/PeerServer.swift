//
//  PeerServer.swift
//  Movie Remote
//
//  Created by Khant Linn on 21/10/2026.
//


import Foundation
import MultipeerConnectivity
import Combine

// Fallback for mac target if SharedTypes.swift isn't in target membership
enum RemoteCommand: String, Codable {
    case togglePlayPause
    case backward
    case forward
    case volumeDown
    case volumeUp
}

@MainActor
final class PeerServer: NSObject, ObservableObject {
    @Published var isConnected: Bool = false
    @Published var connectedPeerName: String? = nil
    @Published var log: [String] = []

    private let serviceType = "movie-remote" // must match iOS
    private let myPeerID = MCPeerID(displayName: Host.current().localizedName ?? "Mac")
    private var session: MCSession!
    private var advertiser: MCNearbyServiceAdvertiser?

    override init() {
        super.init()
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
    }

    func start() {
        log.append("Starting advertiser…")
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func stop() {
        log.append("Stopping advertiser…")
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        session.disconnect()
        isConnected = false
        connectedPeerName = nil
    }

    private func handle(payload: CommandPayload) {
        log.append("Received command: \(payload.command.rawValue)")
        
        switch payload.command {
           case .togglePlayPause:
               MacRemoteAction.playPause()

           case .backward:
               MacRemoteAction.seekBackward()

           case .forward:
               MacRemoteAction.seekForward()
            
            case .volumeUp:
                MacVolumeControl.volumeUp()

            case .volumeDown:
                MacVolumeControl.volumeDown()

           }
    }
}

// MARK: - Codable payload shared with iOS
struct CommandPayload: Codable {
    let command: RemoteCommand
}

// MARK: - MCSessionDelegate
extension PeerServer: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        Task { @MainActor in
            self.isConnected = state == .connected
            self.connectedPeerName = session.connectedPeers.first?.displayName
            self.log.append("Peer \(peerID.displayName) state: \(state.rawValue)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let payload = try JSONDecoder().decode(CommandPayload.self, from: data)
            Task { @MainActor in self.handle(payload: payload) }
        } catch {
            Task { @MainActor in self.log.append("Decode error: \(error)") }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

// MARK: - Advertiser
extension PeerServer: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        log.append("Invitation from \(peerID.displayName). Accepting…")
        invitationHandler(true, session)
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        log.append("Advertiser failed: \(error.localizedDescription)")
    }
}

