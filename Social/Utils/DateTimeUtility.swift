//
//  DateTimeUtility.swift
//  Social
//
//  Created by Gourob Mazumder on 5/11/25.
//

import Foundation


struct DateTimeUtility {
    static func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"

        guard let date = inputFormatter.date(from: dateString) else { return "" }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.doesRelativeDateFormatting = true

        return displayFormatter.string(from: date)
    }
}
