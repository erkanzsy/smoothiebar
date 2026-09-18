import SwiftUI

struct RootView: View {
    @StateObject private var engine = DayEngine()

    var body: some View {
        VStack(spacing: 16) {
            header
            if case .chopping = engine.phase {
                Spacer()
                ChopView(engine: engine)
                Spacer()
            } else {
                Spacer()
                orderCard
                Spacer()
                blenderView
                fruitPad
                serveButton
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .fullScreenCover(isPresented: dayEndPresented) {
            DayEndView(engine: engine)
        }
    }

    private var dayEndPresented: Binding<Bool> {
        Binding(
            get: {
                if case .dayEnd = engine.phase { return true }
                return false
            },
            set: { _ in }
        )
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Gün \(engine.day)").font(.headline)
                Text("Sipariş \(min(engine.servedCount + 1, DayEngine.ordersPerDay))/\(DayEngine.ordersPerDay))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(engine.score) puan")
                .font(.title2.bold())
                .monospacedDigit()
        }
    }

    @ViewBuilder
    private var orderCard: some View {
        switch engine.phase {
        case .idle:
            Button("Günü başlat") {
                engine.startDay()
            }
            .buttonStyle(.borderedProminent)
        case .preparing:
            if let order = engine.currentOrder {
                VStack(spacing: 12) {
                    Text("Sipariş")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(order.recipeText)
                        .font(.system(size: 44))
                    Text("Doğru kombinasyonu hazırla")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    PatienceBarView(engine: engine)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(.white, in: .rect(cornerRadius: 20))
                .shadow(radius: 4, y: 2)
            }
        case .chopping:
            EmptyView()
        case .feedback(let message):
            Text(message)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .padding()
        case .dayEnd:
            EmptyView()
        }
    }

    private var blenderView: some View {
        HStack(spacing: 8) {
            ForEach(Array(engine.blender.enumerated()), id: \.offset) { index, fruit in
                Text(fruit.emoji)
                    .font(.title)
                    .onTapGesture { engine.removeFruit(at: index) }
            }
            if engine.blender.isEmpty {
                Text("Meyve ekle")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 64)
        .background(.white, in: .rect(cornerRadius: 16))
    }

    private var fruitPad: some View {
        HStack(spacing: 12) {
            ForEach(Fruit.allCases) { fruit in
                Button {
                    engine.addFruit(fruit)
                } label: {
                    Text(fruit.emoji)
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(fruit.color.opacity(0.15), in: .rect(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var serveButton: some View {
        switch engine.phase {
        case .preparing:
            HStack(spacing: 12) {
                if !engine.isChopped {
                    Button {
                        engine.beginChopping()
                    } label: {
                        Text("✂️ Doğra")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(engine.blender.isEmpty)
                }
                Button {
                    engine.serve()
                } label: {
                    Text(engine.isChopped ? "🥤 Servis Et" : "Karıştır ve Servis Et")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(engine.blender.isEmpty)
            }
        case .feedback, .chopping, .dayEnd:
            EmptyView()
        default:
            EmptyView()
        }
    }
}
