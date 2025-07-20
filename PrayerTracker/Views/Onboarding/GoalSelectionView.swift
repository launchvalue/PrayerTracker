import SwiftUI

struct GoalSelectionView: View {
    @Binding var dailyGoal: Int
    private let goalOptions = Array(stride(from: 5, through: 30, by: 5))

    var body: some View {
        VStack(spacing: 30) {
            Text("Set Your Daily Goal")
                .font(DesignSystem.Typography.title1())
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("How many Qada prayers do you aim to complete each day?")
                .font(DesignSystem.Typography.body())
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Picker("Daily Goal", selection: $dailyGoal) {
                ForEach(goalOptions, id: \.self) { goal in
                    Text("\(goal) prayers").tag(goal)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .padding(.horizontal)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)


            Spacer()
        }
        .padding()
        .onAppear {
            if !goalOptions.contains(dailyGoal) {
                dailyGoal = 5
            }
        }
    }
}