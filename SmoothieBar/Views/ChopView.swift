import SwiftUI

struct ChopView: View {
    @ObservedObject var engine: DayEngine
    @State private var startedAt = Date.now
    @State private var tapCount = 0
    @State private var flash: ChopResult?

    private let needlePeriod = 1.1

    var body: some View {
        VStack(spacing: 20) {
            PatienceBarView(engine: engine)
            board
            timingTrack
            Text(flash == .perfect ? "MÜKEMMEL! ⚡" : "Ekrana dokun ve doğra! ✂️")
                .font(.title3.bold())
                .foregroundStyle(flash == .perfect ? .green : .secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture { chop() }
        .sensoryFeedback(.impact(weight: .heavy), trigger: tapCount)
        .sensoryFeedback(.success, trigger: engine.chopIndex)
        .onAppear { startedAt = .now }
    }

    private func chop() {
        tapCount += 1
        if let result = engine.tapChop(needleAt: needlePosition(at: .now)) {
            flash = result
        }
    }

    private func needlePosition(at date: Date) -> Double {
        let t = date.timeIntervalSince(startedAt).truncatingRemainder(dividingBy: needlePeriod) / needlePeriod
        return t < 0.5 ? t * 2 : 2 - t * 2
    }

    private var board: some View {
        VStack(spacing: 16) {
            Text(currentFruitEmoji)
                .font(.system(size: 96))
                .scaleEffect(flash == .perfect ? 1.15 : 1)
                .animation(.spring(duration: 0.15), value: tapCount)
            fruitQueue
            ProgressView(value: engine.chopProgress)
                .tint(.white)
        }
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(
            LinearGradient(
                colors: [Color(red: 0.78, green: 0.58, blue: 0.36), Color(red: 0.62, green: 0.44, blue: 0.26)],
                startPoint: .top, endPoint: .bottom
            ),
            in: .rect(cornerRadius: 24)
        )
        .shadow(radius: 4, y: 2)
    }

    private var currentFruitEmoji: String {
        engine.blender.indices.contains(engine.chopIndex) ? engine.blender[engine.chopIndex].emoji : "🥤"
    }

    private var fruitQueue: some View {
        HStack(spacing: 12) {
            ForEach(Array(engine.blender.enumerated()), id: \.offset) { index, fruit in
                Text(fruit.emoji)
                    .font(.title2)
                    .opacity(index < engine.chopIndex ? 0.35 : 1)
                    .overlay {
                        if index == engine.chopIndex {
                            Circle()
                                .stroke(.white, lineWidth: 2)
                                .frame(width: 38, height: 38)
                        }
                    }
            }
        }
    }

    private var timingTrack: some View {
        TimelineView(.animation) { context in
            let position = needlePosition(at: context.date)
            return GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(.quaternary)
                    Capsule()
                        .fill(.green.opacity(0.4))
                        .frame(width: geo.size.width * (engine.sweetSpot.upperBound - engine.sweetSpot.lowerBound))
                        .offset(x: geo.size.width * engine.sweetSpot.lowerBound)
                    Capsule()
                        .fill(.primary)
                        .frame(width: 6, height: 24)
                        .offset(x: geo.size.width * position - 3)
                }
            }
            .frame(height: 24)
        }
    }
}
