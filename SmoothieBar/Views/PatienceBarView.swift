import SwiftUI

struct PatienceBarView: View {
    @ObservedObject var engine: DayEngine

    var body: some View {
        HStack(spacing: 8) {
            Text("🧍")
                .font(.title3)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.quaternary)
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * fraction)
                        .animation(.linear(duration: 0.1), value: fraction)
                }
            }
            .frame(height: 8)
        }
    }

    private var fraction: Double {
        max(0, min(1, engine.remainingPatience / engine.patienceDuration))
    }

    private var color: Color {
        fraction > 0.5 ? .green : fraction > 0.25 ? .orange : .red
    }
}
