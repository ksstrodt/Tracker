//
//  Extensions.swift
//  Tracker
//
//  Created by bot on 29.07.2026.
//

import UIKit

// MARK: - TrackerCoreData Extension
extension TrackerCoreData {
    func toTracker() -> Tracker? {
        guard let id = id,
              let name = name,
              let emoji = emoji,
              let colorHex = colorHex,
              let scheduleDays = scheduleDays else {
            return nil
        }
        
        let color = UIColor(hexString: colorHex) ?? .black
        
        let schedule: [WeekDay] = scheduleDays.split(separator: ",").compactMap { dayString in
            guard let index = Int(dayString), index < WeekDay.allDays.count else {
                return nil
            }
            return WeekDay.allDays[index]
        }
        
        return Tracker(
            id: id,
            name: name,
            emoji: emoji,
            color: color,
            schedule: schedule
        )
    }
}

// MARK: - TrackerCategoryCoreData Extension
extension TrackerCategoryCoreData {
    func toTrackerCategory(with trackers: [Tracker]) -> TrackerCategory {
        let title = self.title ?? "Без категории"
        return TrackerCategory(title: title, trackers: trackers)
    }
}

// MARK: - TrackerRecordCoreData Extension
extension TrackerRecordCoreData {
    func toTrackerRecord() -> TrackerRecord? {
        guard let trackerId = trackerId,
              let date = date else {
            return nil
        }
        return TrackerRecord(trackerId: trackerId, date: date)
    }
}

// MARK: - UIColor Extension
extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
    
    convenience init?(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        if length == 6 {
            let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            let blue = CGFloat(rgb & 0x0000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: 1.0)
        } else if length == 8 {
            let red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            let green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            let blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            let alpha = CGFloat(rgb & 0x000000FF) / 255.0
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return nil
        }
    }
}
