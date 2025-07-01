import SwiftUI

struct EstimatedCompletionCard: View {
    let profile: UserProfile

    private var estimatedCompletionDate: String {
        guard let debt = profile.debt else { return "N/A" }
        let totalRemaining = debt.fajrOwed + debt.dhuhrOwed + debt.asrOwed + debt.maghribOwed + debt.ishaOwed

        if totalRemaining <= 0 {
            return "All caught up!"
        }
        // Assuming user makes up 1 prayer debt per day in addition to daily prayers
        if let completionDate = Calendar.current.date(byAdding: .day, value: totalRemaining, to: Date()) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: completionDate)
        }
        return "Calculating..."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Estimated Completion")
                .font(.title2)
                .fontWeight(.bold)

            Text(estimatedCompletionDate)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
