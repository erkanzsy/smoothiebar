import SwiftUI

struct DayEndView: View {
    @ObservedObject var engine: DayEngine

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("🌆")
                .font(.system(size: 64))
            Text("Gün \(engine.day) Bitti")
                .font(.largeTitle.bold())
            stats
            Spacer()
            Button {
                engine.advanceDay()
            } label: {
                Text("Yarın")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    private var stats: some View {
        VStack(spacing: 16) {
            stat("💰", "Kazanç", "\(engine.dayScore)")
            stat("🥤", "Servis Edilen", "\(engine.servedCount - engine.lostCount)/\(DayEngine.ordersPerDay)")
            stat("🏃", "Kaçan Müşteri", "\(engine.lostCount)")
            Divider()
            stat("🏆", "Toplam Puan", "\(engine.score)")
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.white, in: .rect(cornerRadius: 20))
        .shadow(radius: 4, y: 2)
    }

    private func stat(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack {
            Text("\(icon) \(label)")
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .bold()
                .monospacedDigit()
        }
    }
}
