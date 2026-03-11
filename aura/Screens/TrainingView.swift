import SwiftUI

struct TrainingView: View {
    let categories = MockData.trainingCategories
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
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
                        ForEach(categories) { category in
                            TrainingCategoryCard(category: category)
                        }
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
