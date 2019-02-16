import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get("") { req in
        req.redirect(to: "members")
    }

    router.get("members") { req -> Future<View> in
        return Member.query(on: req).all().flatMap(to: View.self) { members in
            let average = Average(
                level:          Double(members.reduce(0) { $0 + $1.level })         / Double(members.count),
                apprentice:     Double(members.reduce(0) { $0 + $1.apprentice })    / Double(members.count),
                guru:           Double(members.reduce(0) { $0 + $1.guru })          / Double(members.count),
                master:         Double(members.reduce(0) { $0 + $1.master })        / Double(members.count),
                enlightened:    Double(members.reduce(0) { $0 + $1.enlightened })   / Double(members.count),
                burned:         Double(members.reduce(0) { $0 + $1.burned })        / Double(members.count),
                unlocksPerDay:  Double(members.reduce(0) { $0 + $1.unlocksPerDay }) / Double(members.count)
            )

            return try req.view().render("Members/index", MembersIndexContext(members: members, average: average))
        }
    }

    router.get("members", "new") { req -> Future<View> in
        return try req.view().render("Members/new", MembersNewContext())
    }

    router.post("members") { req -> Future<View> in
        return try req.content.decode(MemberInput.self).flatMap { memberInput in
            return Member(memberInput: memberInput).create(on: req).flatMap { member in
                try req.view().render("success")
            }
        }
    }
}
