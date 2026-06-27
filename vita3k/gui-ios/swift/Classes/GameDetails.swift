//
//  GameDetails.swift
//  Vion
//
//  Created by Jarrod Norwell on 7/5/2026.
//

import Foundation

class GameDetails: Codable {
    let appVersion: String
    let category: String
    let contentidentifier: String
    let additionalContent: String
    let savedata: String
    let parentalLevel: String
    let stitle: String
    let title: String
    let titleIdentifier: String
    let path: String
    let iconPath: String

    init(_ applicationEntry: ApplicationEntry) {
        appVersion = String(applicationEntry.app_ver)
        category = String(applicationEntry.category)
        contentidentifier = String(applicationEntry.content_id)
        additionalContent = String(applicationEntry.addcont)
        savedata = String(applicationEntry.savedata)
        parentalLevel = String(applicationEntry.parental_level)
        stitle = String(applicationEntry.stitle)
        title = String(applicationEntry.title)
        titleIdentifier = String(applicationEntry.title_id)
        path = String(applicationEntry.path)
        iconPath = String(applicationEntry.icon_path)
    }
}
