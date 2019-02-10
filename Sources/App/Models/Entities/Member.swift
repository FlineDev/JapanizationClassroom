//
//  Member.swift
//  App
//
//  Created by Cihat Gündüz on 09.02.19.
//

import FluentPostgreSQL
import HandySwift
import SwiftyJSON
import Vapor

/// A simple user.
final class Member: PostgreSQLModel {
    /// The unique identifier for this user.
    var id: Int?

    var username: String
    var waniKaniStartDate: Date
    var ajcJoinDate: Date
    var nativeLanguages: String?

    // MARK: Current WaniKani user data.
    var level: Int = 0
    var apprentice: Int = 0
    var guru: Int = 0
    var master: Int = 0
    var enlightened: Int = 0
    var burned: Int = 0

    var unlocked: Int {
        return apprentice + guru + master + enlightened + burned
    }

    var unlocksPerDay: Double {
        return Double(unlocked) / Date().timeIntervalSince(waniKaniStartDate).days
    }

    /// Creates a new user.
    init(id: Int? = nil, username: String, waniKaniStartDate: Date, nativeLanguages: String?) {
        self.id = id
        self.username = username
        self.waniKaniStartDate = waniKaniStartDate
        self.nativeLanguages = nativeLanguages
        self.ajcJoinDate = Date()
    }

    struct UpdateResult {
        let success: Bool
        let info: String?
    }

    func fetchDataFromWaniKani(on connectable: DatabaseConnectable) throws -> Future<UpdateResult> {
        let profileContents = try String(contentsOf: URL(string: "https://www.wanikani.com/users/\(username)")!)
        let srsCountsRegex = try Regex("var srsCounts = (.+\\});\\n")

        guard let srsCountsString = srsCountsRegex.firstMatch(in: profileContents)?.captures.first else {
            return connectable.future(UpdateResult(success: false, info: "No user with name '\(username)' found."))
        }

        let srsCountsJson = JSON(parseJSON: srsCountsString!)
        let userInformationJson = srsCountsJson["user_information"]
        let requestedInformation = srsCountsJson["requested_information"]

        let valuesBeforeUpdate = [level, apprentice, guru, master, enlightened, burned]

        level           = userInformationJson["level"].intValue
        apprentice      = requestedInformation["apprentice"]["total"].intValue
        guru            = requestedInformation["guru"]["total"].intValue
        master          = requestedInformation["master"]["total"].intValue
        enlightened     = requestedInformation["enlighten"]["total"].intValue
        burned          = requestedInformation["burned"]["total"].intValue

        let valuesAfterUpdate = [level, apprentice, guru, master, enlightened, burned]

        guard valuesAfterUpdate != valuesBeforeUpdate else {
            if fluentUpdatedAt != nil && Date().timeIntervalSince(fluentUpdatedAt!) > .days(7) {
                // TODO: send email to member / post message to thread
                return connectable.future(UpdateResult(success: false, info: "User '\(username)' didn't have any changes since more than 7 days."))
            } else {
                if fluentUpdatedAt != nil && Date().timeIntervalSince(fluentUpdatedAt!) > .days(5) {
                    // TODO: send warning email to member
                }

                return connectable.future(UpdateResult(success: true, info: "Nothing changed for user '\(username)' since last update."))
            }
        }

        guard level > 3 else {
            return connectable.future(UpdateResult(success: false, info: "User '\(username)' must be above level 3, but is at level \(level)."))
        }

        return connectable.future(UpdateResult(success: true, info: nil))
    }
}

extension Member: Content { }

extension Member: PostgreSQLMigration { }
