import SwiftUI

struct HeaderView: View {
    let userName: String
    let hijriDate: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dashboard")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Assalamu Alaikum, \(userName)")
                .font(.body)
                .foregroundColor(.secondary)
            
            Text(hijriDate)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}

#Preview {
    HeaderView(
        userName: "Ahmad",
        hijriDate: "15 Muharram 1446 AH"
    )
    .padding()
}
