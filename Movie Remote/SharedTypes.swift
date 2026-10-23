import Foundation

public enum RemoteCommand: String, Codable {
    case togglePlayPause
    case backward
    case forward
    case volumeDown
    case volumeUp
}
