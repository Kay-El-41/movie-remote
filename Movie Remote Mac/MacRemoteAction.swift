//
//  MacRemoteAction.swift
//  Movie Remote
//
//  Created by Khant Linn on 22/10/2026.
//


import AppKit
import CoreGraphics

enum MacRemoteAction {
    static func pressKey(_ keyCode: CGKeyCode) {
        guard let source = CGEventSource(stateID: .hidSystemState),
              let keyDown = CGEvent(
                keyboardEventSource: source,
                virtualKey: keyCode,
                keyDown: true
              ),
              let keyUp = CGEvent(
                keyboardEventSource: source,
                virtualKey: keyCode,
                keyDown: false
              ) else {
            print("Failed to create keyboard event")
            return
        }

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }

    static func playPause() {
        pressKey(49) // Space
    }

    static func seekBackward() {
        pressKey(123) // Left arrow
    }

    static func seekForward() {
        pressKey(124) // Right arrow
    }
}

