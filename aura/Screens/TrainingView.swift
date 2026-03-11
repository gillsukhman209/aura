import SwiftUI

struct TrainingView: View {
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private let categories: [(name: String, subtitle: String, icon: String, color: Color)] = [
        ("Strength Training", "Physical power & endurance", StatType.strength.icon, StatType.strength.color),
        ("Focus Training", "Concentration & deep work", StatType.focus.icon, StatType.focus.color),
        ("Discipline Training", "Mental resilience & consistency", StatType.discipline.icon, StatType.discipline.color),
        ("Knowledge Training", "Learning & wisdom", StatType.knowledge.icon, StatType.knowledge.color),
    ]

    var body: some View {
        ZStack {
            StarfieldBackground(starCount: 180)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("TRAINING")
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .foregroundColor(.white)
                        .tracking(4)
                        .padding(.top, 12)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0..<categories.count, id: \.self) { i in
                            let cat = categories[i]
                            TrainingCategoryCard(
                                name: cat.name,
                                subtitle: cat.subtitle,
                                icon: cat.icon,
                                color: cat.color
                            )
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
