import Foundation

// MARK: - Roast Intensity

enum RoastIntensity: String, CaseIterable, Identifiable {
    case mild
    case brutal
    case unhinged

    var id: String { rawValue }

    var label: String {
        switch self {
        case .mild: "Mild"
        case .brutal: "Brutal"
        case .unhinged: "Unhinged"
        }
    }

    var description: String {
        switch self {
        case .mild: "Motivational with light teasing"
        case .brutal: "Harsh but funny"
        case .unhinged: "Maximum savagery"
        }
    }
}

// MARK: - Roast Context

struct RoastContext {
    let habitCount: Int
    let completedCount: Int
    let remainingCount: Int
    let habitNames: [String]
    let streak: Int
    let bestStreak: Int
    let rank: String
    let consistency: Int
    let discipline: Int
    let apLost: Int
    let oldStreak: Int
    let intensity: RoastIntensity

    /// A random incomplete habit name, or fallback.
    var randomHabitName: String {
        habitNames.randomElement() ?? "your habits"
    }
}

// MARK: - Roast Template

private struct RoastTemplate {
    let text: String
    let minIntensity: RoastIntensity
    let requiresStreak: Bool

    init(_ text: String, intensity: RoastIntensity = .brutal, requiresStreak: Bool = false) {
        self.text = text
        self.minIntensity = intensity
        self.requiresStreak = requiresStreak
    }
}

// MARK: - Roast Engine

struct RoastEngine {

    // MARK: - Public API

    static func morningRoast(context: RoastContext) -> String {
        resolve(pick(from: morningTemplates, context: context), context: context)
    }

    static func eveningRoast(context: RoastContext) -> String {
        resolve(pick(from: eveningTemplates, context: context), context: context)
    }

    static func streakDeathRoast(context: RoastContext) -> String {
        resolve(pick(from: streakDeathTemplates, context: context), context: context)
    }

    static func inactivityRoast(days: Int, context: RoastContext) -> String {
        let templates = days >= 5 ? inactivity5DayTemplates : inactivity2DayTemplates
        return resolve(pick(from: templates, context: context), context: context)
    }

    static func penaltyRoast(context: RoastContext) -> String {
        resolve(pick(from: penaltyTemplates, context: context), context: context)
    }

    static func milestoneRoast(streak: Int) -> String {
        if let specific = milestoneTemplates[streak] {
            return specific.randomElement() ?? "Nice streak."
        }
        // Fallback for non-milestone values (shouldn't happen but safe)
        return "\(streak) days. Not bad."
    }

    // MARK: - Template Selection

    private static func pick(from templates: [RoastTemplate], context: RoastContext) -> String {
        let eligible = templates.filter { template in
            // Filter by intensity
            let intensityOK: Bool
            switch context.intensity {
            case .mild: intensityOK = template.minIntensity == .mild
            case .brutal: intensityOK = template.minIntensity != .unhinged
            case .unhinged: intensityOK = true
            }

            // Filter by streak requirement
            let streakOK = !template.requiresStreak || context.streak >= 3

            return intensityOK && streakOK
        }

        return eligible.randomElement()?.text ?? templates.first?.text ?? "Open the app."
    }

    // MARK: - Placeholder Resolution

    private static func resolve(_ template: String, context: RoastContext) -> String {
        template
            .replacingOccurrences(of: "{count}", with: "\(context.habitCount)")
            .replacingOccurrences(of: "{done}", with: "\(context.completedCount)")
            .replacingOccurrences(of: "{remaining}", with: "\(context.remainingCount)")
            .replacingOccurrences(of: "{total}", with: "\(context.habitCount)")
            .replacingOccurrences(of: "{habitName}", with: context.randomHabitName)
            .replacingOccurrences(of: "{streak}", with: "\(context.streak)")
            .replacingOccurrences(of: "{bestStreak}", with: "\(context.bestStreak)")
            .replacingOccurrences(of: "{rank}", with: context.rank)
            .replacingOccurrences(of: "{consistency}", with: "\(context.consistency)")
            .replacingOccurrences(of: "{discipline}", with: "\(context.discipline)")
            .replacingOccurrences(of: "{amount}", with: "\(context.apLost)")
            .replacingOccurrences(of: "{oldStreak}", with: "\(context.oldStreak)")
    }

    // MARK: - Morning Templates

    private static let morningTemplates: [RoastTemplate] = [
        // Mild
        RoastTemplate("New day, {count} habits on deck. You've got this... probably.", intensity: .mild),
        RoastTemplate("Good morning! {count} habits today. Your {streak}-day streak is counting on you.", intensity: .mild, requiresStreak: true),
        RoastTemplate("Rise and shine. {count} habits waiting. Don't let yesterday's momentum die.", intensity: .mild),
        RoastTemplate("{count} habits today. Your future self is watching. Make them proud.", intensity: .mild),
        RoastTemplate("Morning. {consistency}% consistency so far. Let's push that higher today.", intensity: .mild),

        // Brutal
        RoastTemplate("You have {count} habits today. At {consistency}% consistency, I wouldn't bet on you either.", intensity: .brutal),
        RoastTemplate("Good morning, {rank}. {count} habits and a {streak}-day streak to protect. Try not to be mid today.", intensity: .brutal, requiresStreak: true),
        RoastTemplate("Your discipline stat is {discipline}. That's embarrassing. {count} habits today — prove me wrong.", intensity: .brutal),
        RoastTemplate("Another day, another chance for you to fumble your {streak}-day streak.", intensity: .brutal, requiresStreak: true),
        RoastTemplate("You're a {rank} with {consistency}% consistency. That's not the flex you think it is.", intensity: .brutal),
        RoastTemplate("{count} habits today. The bar is on the floor and you still trip over it.", intensity: .brutal),
        RoastTemplate("Wake up. {count} habits. Your aura isn't going to build itself. Obviously.", intensity: .brutal),
        RoastTemplate("Good morning to everyone except people with {consistency}% consistency. Oh wait, that's you.", intensity: .brutal),

        // Unhinged
        RoastTemplate("Congrats on waking up. Now do something with your life. {count} habits. Go.", intensity: .unhinged),
        RoastTemplate("Your {rank} rank is a participation trophy at this point. {count} habits today. Actually try.", intensity: .unhinged),
        RoastTemplate("The only thing consistent about you is your inconsistency. {consistency}%. Pathetic. {count} habits. Move.", intensity: .unhinged),
        RoastTemplate("{count} habits today. Your discipline stat is {discipline}. Even NPCs have more willpower.", intensity: .unhinged),
        RoastTemplate("Rise and grind? You don't grind. You scroll. {count} habits today. Shock everyone including yourself.", intensity: .unhinged),
    ]

    // MARK: - Evening Templates

    private static let eveningTemplates: [RoastTemplate] = [
        // Mild
        RoastTemplate("Hey, {remaining} habits left today. Still time to finish strong.", intensity: .mild),
        RoastTemplate("You've done {done}/{total} so far. Just {remaining} more to go. You can do it.", intensity: .mild),
        RoastTemplate("Evening check-in: {remaining} habits remaining. Don't leave them for tomorrow.", intensity: .mild),
        RoastTemplate("Almost done! {done} out of {total} complete. Finish the rest before bed.", intensity: .mild),

        // Brutal
        RoastTemplate("You did {done}/{total} habits today. '{habitName}' is literally staring at you. Get up.", intensity: .brutal),
        RoastTemplate("{remaining} habits left and you're on your phone doing nothing. Classic.", intensity: .brutal),
        RoastTemplate("Your streak is {streak} days. It's about to be 0. You have until midnight.", intensity: .brutal, requiresStreak: true),
        RoastTemplate("Everyone else finished their habits. You're still sitting on {remaining} incomplete. Tragic.", intensity: .brutal),
        RoastTemplate("{done}/{total} done. The other {remaining}? Apparently too hard for a {rank}.", intensity: .brutal),
        RoastTemplate("It's getting late and '{habitName}' isn't going to complete itself. Or maybe you think it will.", intensity: .brutal),
        RoastTemplate("You've had all day. {remaining} habits undone. What exactly were you doing?", intensity: .brutal),

        // Unhinged
        RoastTemplate("You skipped '{habitName}' again? At this point just delete the app.", intensity: .unhinged),
        RoastTemplate("{remaining} habits left. Your excuses are getting more creative than your effort.", intensity: .unhinged),
        RoastTemplate("{done}/{total} habits. Congrats on doing the bare minimum. Oh wait, you didn't even do that.", intensity: .unhinged),
        RoastTemplate("'{habitName}' takes like 10 minutes and you still can't be bothered. Genuinely embarrassing.", intensity: .unhinged),
        RoastTemplate("Your {rank} rank is carrying dead weight. That dead weight is you. {remaining} habits left.", intensity: .unhinged),
    ]

    // MARK: - Streak Death Warning Templates

    private static let streakDeathTemplates: [RoastTemplate] = [
        // Mild
        RoastTemplate("Heads up — your {streak}-day streak is at risk. {remaining} habits left before midnight.", intensity: .mild),
        RoastTemplate("2 hours left. Your {streak}-day streak needs you. {remaining} habits to go.", intensity: .mild),
        RoastTemplate("Your streak is on the line. {remaining} habits, 2 hours. You can still save it.", intensity: .mild),

        // Brutal
        RoastTemplate("Your {streak}-day streak dies in 2 hours. {remaining} habits left. Was it worth it?", intensity: .brutal),
        RoastTemplate("{streak} days of discipline, about to be erased because you couldn't do '{habitName}'. Embarrassing.", intensity: .brutal),
        RoastTemplate("Your best streak is {bestStreak} days. You're at {streak} right now. Don't choke.", intensity: .brutal),
        RoastTemplate("2 hours left. {streak}-day streak on the line. But sure, keep scrolling.", intensity: .brutal),
        RoastTemplate("{remaining} habits and a {streak}-day streak about to flatline. This is your fault.", intensity: .brutal),

        // Unhinged
        RoastTemplate("{streak} days. All of it — gone. Because you couldn't do {remaining} simple habits. Clown behavior.", intensity: .unhinged),
        RoastTemplate("Your {streak}-day streak is begging for its life and you're ignoring it. Cold.", intensity: .unhinged),
        RoastTemplate("In 2 hours your streak resets to 0. {streak} days wasted. You're actually trolling yourself.", intensity: .unhinged),
        RoastTemplate("RIP your {streak}-day streak. Cause of death: you being lazy. {remaining} habits left. Last chance.", intensity: .unhinged),
    ]

    // MARK: - Inactivity 2-Day Templates

    private static let inactivity2DayTemplates: [RoastTemplate] = [
        // Mild
        RoastTemplate("It's been 2 days since you opened Aura. Your habits are waiting for you.", intensity: .mild),
        RoastTemplate("Hey, you haven't checked in for 2 days. Don't let your progress slip away.", intensity: .mild),
        RoastTemplate("2 days without logging. Your streak might be gone, but you can start fresh today.", intensity: .mild),

        // Brutal
        RoastTemplate("It's been 2 days. Your streak is dead. Your habits are collecting dust. You good?", intensity: .brutal),
        RoastTemplate("Haven't opened Aura in 2 days. Your {rank} rank is embarrassed to be associated with you.", intensity: .brutal),
        RoastTemplate("2 days absent. -40 AP gone. Your character is literally getting weaker while you ignore this.", intensity: .brutal),
        RoastTemplate("2 days off the grid. Your stats are rotting. Your discipline stat weeps.", intensity: .brutal),

        // Unhinged
        RoastTemplate("2 days. You ghosted your own self-improvement app. That's a new low even for you.", intensity: .unhinged),
        RoastTemplate("Your habits filed a missing persons report. It's been 2 days. Show up or give up.", intensity: .unhinged),
        RoastTemplate("2 days absent. Your aura is decaying in real time. Even your phone is disappointed.", intensity: .unhinged),
    ]

    // MARK: - Inactivity 5-Day Templates

    private static let inactivity5DayTemplates: [RoastTemplate] = [
        // Mild
        RoastTemplate("It's been 5 days. Your streak is gone, but your journey isn't. Come back.", intensity: .mild),
        RoastTemplate("5 days away. That's okay — what matters is coming back. Open Aura.", intensity: .mild),

        // Brutal
        RoastTemplate("5 days. Your aura is in shambles. Even Wood rank players are judging you.", intensity: .brutal),
        RoastTemplate("It's been 5 days. At this point I'm not even mad, just disappointed.", intensity: .brutal),
        RoastTemplate("You ghosted your own self-improvement. It's been 5 days. Your stats are crying.", intensity: .brutal),
        RoastTemplate("5 days absent. Your character sheet looks like an obituary. Come fix it.", intensity: .brutal),

        // Unhinged
        RoastTemplate("5 days. Five. You have the discipline of a goldfish. Your {rank} rank means nothing now.", intensity: .unhinged),
        RoastTemplate("At 5 days absent your aura isn't low — it's negative. You're actively making the world worse.", intensity: .unhinged),
        RoastTemplate("5 days gone. Your habits didn't quit on you — you quit on them. That's worse.", intensity: .unhinged),
    ]

    // MARK: - Penalty Templates

    private static let penaltyTemplates: [RoastTemplate] = [
        // Mild
        RoastTemplate("You lost {amount} AP yesterday. Today's a new chance. Don't waste it.", intensity: .mild),
        RoastTemplate("-{amount} AP from yesterday. Rough, but you can earn it back. Open the app.", intensity: .mild),
        RoastTemplate("Yesterday cost you {amount} AP. Time to bounce back.", intensity: .mild),

        // Brutal
        RoastTemplate("You lost {amount} AP yesterday. Your streak? Gone. Your discipline? Nonexistent.", intensity: .brutal),
        RoastTemplate("Streak reset to 0. You had {oldStreak} days. All that work, wasted. Open the app.", intensity: .brutal),
        RoastTemplate("-{amount} AP. That's what quitting looks like. Get back in here.", intensity: .brutal),
        RoastTemplate("{amount} aura points vanished because you couldn't finish your habits. Tragic backstory.", intensity: .brutal),
        RoastTemplate("Your streak went from {oldStreak} to 0 overnight. That's not a setback, that's self-sabotage.", intensity: .brutal),

        // Unhinged
        RoastTemplate("-{amount} AP. Your character got nerfed because you're the worst player in your own game.", intensity: .unhinged),
        RoastTemplate("{oldStreak}-day streak → 0. You speedran failure. Impressive, honestly.", intensity: .unhinged),
        RoastTemplate("Lost {amount} AP. At this rate you'll be demoted to a rank that doesn't exist yet.", intensity: .unhinged),
        RoastTemplate("Your aura took a {amount} AP hit. Even the penalty system feels bad for you. It shouldn't.", intensity: .unhinged),
    ]

    // MARK: - Milestone Templates

    private static let milestoneTemplates: [Int: [String]] = [
        7: [
            "7 days straight. Okay, maybe you're not completely useless.",
            "A full week. Most people can't even do 3 days. Mildly impressed.",
            "7-day streak. The bare minimum of discipline. But hey, it's a start.",
        ],
        14: [
            "2 weeks. Most people quit by now. You didn't. Respect... barely.",
            "14-day streak. You're officially more disciplined than 90% of app users. Low bar though.",
            "2 weeks in. Your habits are becoming personality traits. Scary.",
        ],
        30: [
            "30-day streak. You went from NPC to main character. Don't let it drop.",
            "A full month. Your brain literally rewired itself. You're different now.",
            "30 days. That's not a streak, that's a lifestyle. Keep going.",
        ],
        60: [
            "60 days. You're not playing anymore. This is who you are now.",
            "2 months. Most people forgot their New Year's resolution by now. You didn't.",
            "60-day streak. Your aura is genuinely intimidating. Well done.",
        ],
        90: [
            "90 days. You're actually built different. I'll admit it.",
            "Quarter of a year. Your discipline stat must be through the roof.",
            "90 days straight. You have my respect. Don't get comfortable.",
        ],
        180: [
            "180 days. Half a year. You're in the top 0.1% of humans. Not exaggerating.",
            "6 months of daily discipline. Your aura is visible from space.",
            "180-day streak. Legends are made of less. Keep going.",
        ],
        365: [
            "365 days. A full year. You're actually insane. Screenshot this.",
            "One. Full. Year. You are the main character. No debate.",
            "365-day streak. The app was supposed to motivate you. Now you motivate the app.",
        ],
    ]
}
