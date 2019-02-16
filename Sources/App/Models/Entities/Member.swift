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

    var apiKey: String
    var waniKaniStartDate: Date
    var ajcJoinDate: Date
    var nativeLanguages: String?

    // MARK: Current WaniKani user data.
    var username: String
    var level: Int
    var apprentice: Int
    var guru: Int
    var master: Int
    var enlightened: Int
    var burned: Int

    var unlocked: Int
    var unlocksPerDay: Double

    /// Creates a new user.
    init(memberInput: MemberInput, waniKaniUserSRSDistribution: WaniKaniUserSRSDistribution) {
        self.apiKey = memberInput.apiKey

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        self.waniKaniStartDate = dateFormatter.date(from: memberInput.waniKaniStartDate)!
        self.ajcJoinDate = Date()
        self.nativeLanguages = memberInput.nativeLanguages

        self.username       = waniKaniUserSRSDistribution.userInformation.username
        self.level          = waniKaniUserSRSDistribution.userInformation.level
        self.apprentice     = waniKaniUserSRSDistribution.requestedInformation.apprentice.total
        self.guru           = waniKaniUserSRSDistribution.requestedInformation.guru.total
        self.master         = waniKaniUserSRSDistribution.requestedInformation.master.total
        self.enlightened    = waniKaniUserSRSDistribution.requestedInformation.enlighten.total
        self.burned         = waniKaniUserSRSDistribution.requestedInformation.burned.total

        self.unlocked       = apprentice + guru + master + enlightened + burned
        self.unlocksPerDay  = Double(unlocked) / Date().timeIntervalSince(waniKaniStartDate).days
    }

    func update(with waniKaniUserSRSDistribution: WaniKaniUserSRSDistribution, on connectable: DatabaseConnectable) -> Future<UpdateResult> {
        let valuesBeforeUpdate = [level, apprentice, guru, master, enlightened, burned]

        self.username       = waniKaniUserSRSDistribution.userInformation.username
        self.level          = waniKaniUserSRSDistribution.userInformation.level
        self.apprentice     = waniKaniUserSRSDistribution.requestedInformation.apprentice.total
        self.guru           = waniKaniUserSRSDistribution.requestedInformation.guru.total
        self.master         = waniKaniUserSRSDistribution.requestedInformation.master.total
        self.enlightened    = waniKaniUserSRSDistribution.requestedInformation.enlighten.total
        self.burned         = waniKaniUserSRSDistribution.requestedInformation.burned.total

        self.unlocked       = apprentice + guru + master + enlightened + burned
        self.unlocksPerDay  = Double(unlocked) / Date().timeIntervalSince(waniKaniStartDate).days

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

    struct UpdateResult {
        let success: Bool
        let info: String?
    }
}

extension Member: Content { }

extension Member: PostgreSQLMigration { }
