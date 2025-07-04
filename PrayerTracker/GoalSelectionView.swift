import SwiftUI

struct GoalSelectionView: View {
    @Binding var dailyGoal: Int

    var body: some View {
        ZStack {
            // Background with a subtle gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Text("Set Your Daily Goal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text("How many Qada prayers do you aim to complete each day?")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Picker("Daily Goal", selection: $dailyGoal) {
                    ForEach(Array(stride(from: 5, through: 50, by: 5)), id: \.self) { goal in
                        Text("\(goal) prayers").tag(goal)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .padding(.horizontal, 40)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.vertical)
        }
    }
}