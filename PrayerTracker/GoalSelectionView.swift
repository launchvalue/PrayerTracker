import SwiftUI

struct GoalSelectionView: View {
    @Binding var dailyGoal: Int

    var body: some View {
        VStack {
            Text("Set Your Daily Prayer Goal")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Picker("Daily Goal", selection: $dailyGoal) {
                ForEach(Array(stride(from: 5, through: 30, by: 5)), id: \.self) {
                    Text("\($0) prayers per day")
                }
            }
            .pickerStyle(.wheel)
        }
    }
}