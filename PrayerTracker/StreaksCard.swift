import SwiftUI

struct StreaksCard: View {
    let currentStreak: Int
    let longestStreak: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Streaks")
                .font(.title2)
                .fontWeight(.bold)

            HStack(spacing: 20) {
                VStack {
                    Text("\(currentStreak)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Current Streak")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
                .cornerRadius(10)
                .shadow(radius: 3)

                VStack {
                    Text("\(longestStreak)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Longest Streak")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
                .cornerRadius(10)
                .shadow(radius: 3)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
