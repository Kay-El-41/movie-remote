//
//  MacVolumeControl.swift
//  Movie Remote
//
//  Created by Khant Linn on 22/10/2026.
//


import CoreAudio
import CoreFoundation

enum MacVolumeControl {
    private static func defaultOutputDevice() -> AudioDeviceID? {
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var deviceID = AudioDeviceID(0)
        var size = UInt32(MemoryLayout<AudioDeviceID>.size)

        let status = AudioObjectGetPropertyData(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            0,
            nil,
            &size,
            &deviceID
        )

        guard status == noErr, deviceID != 0 else {
            return nil
        }

        return deviceID
    }

    static func changeVolume(by delta: Float) {
        guard let deviceID = defaultOutputDevice() else {
            print("No default output device")
            return
        }

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioObjectPropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        var volume: Float = 0
        var size = UInt32(MemoryLayout<Float>.size)

        let readStatus = AudioObjectGetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            &size,
            &volume
        )

        guard readStatus == noErr else {
            print("Could not read output volume")
            return
        }

        volume = min(max(volume + delta, 0), 1)

        let writeStatus = AudioObjectSetPropertyData(
            deviceID,
            &address,
            0,
            nil,
            size,
            &volume
        )

        if writeStatus != noErr {
            print("Could not change output volume: \(writeStatus)")
        }
    }

    static func volumeUp() {
        changeVolume(by: 0.0625)
    }

    static func volumeDown() {
        changeVolume(by: -0.0625)
    }
}

