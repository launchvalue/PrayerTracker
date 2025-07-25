import SwiftUI

struct PrayerCardView: View {
    let prayerName: String
    @Binding var prayerOwed: Int
    @Binding var prayersCompletedToday: Int
    let onLog: (String) -> Void

    var body: some View {
        HStack {
            Text(prayerName)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Spacer()

            Text("Today: \(prayersCompletedToday)")
                .font(.callout)
                .foregroundColor(.secondary)
                .animation(.spring(), value: prayersCompletedToday)

            Text("\(prayerOwed) Remaining")
                .font(.callout)
                .foregroundColor(.secondary)
                .animation(.spring(), value: prayerOwed)

            Button(action: { 
                onLog(prayerName)
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(prayerOwed == 0 ? .gray : .green)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(prayerOwed == 0)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
        .shadow(color: Color.primary.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
