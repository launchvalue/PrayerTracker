
//
//  DebtCompositionChartView.swift
//  PrayerTracker
//
//  Created by Majd Moussa on 6/29/25.
//

import SwiftUI
import Charts

struct DebtCompositionChartView: View {
    let prayerDebt: PrayerDebt

    private var prayerData: [(PrayerType, Int)] {
        [
            (.fajr, prayerDebt.fajrOwed),
            (.dhuhr, prayerDebt.dhuhrOwed),
            (.asr, prayerDebt.asrOwed),
            (.maghrib, prayerDebt.maghribOwed),
            (.isha, prayerDebt.ishaOwed)
        ]
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Debt Composition")
                .font(.headline)
                .padding(.bottom, 5)

            Chart(prayerData, id: \.0) { prayerType, count in
                SectorMark(
                    angle: .value("Count", count),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .foregroundStyle(by: .value("Prayer", prayerType.rawValue))
                .annotation(position: .overlay) {
                    Text("\\(count)")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .chartForegroundStyleScale([
                PrayerType.fajr.rawValue: PrayerType.fajr.color,
                PrayerType.dhuhr.rawValue: PrayerType.dhuhr.color,
                PrayerType.asr.rawValue: PrayerType.asr.color,
                PrayerType.maghrib.rawValue: PrayerType.maghrib.color,
                PrayerType.isha.rawValue: PrayerType.isha.color
            ])
            .chartLegend(position: .bottom, alignment: .center)
            .frame(height: 250)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct DebtCompositionChartView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleDebt = PrayerDebt(fajrOwed: 10, dhuhrOwed: 5, asrOwed: 8, maghribOwed: 3, ishaOwed: 12)
        DebtCompositionChartView(prayerDebt: sampleDebt)
    }
}
