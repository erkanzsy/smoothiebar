import Foundation
import SwiftUI

enum Fruit: String, CaseIterable, Identifiable {
    case strawberry
    case banana
    case mango
    case kiwi
    case blueberry

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .strawberry: return "🍓"
        case .banana: return "🍌"
        case .mango: return "🥭"
        case .kiwi: return "🥝"
        case .blueberry: return "🫐"
        }
    }

    var color: Color {
        switch self {
        case .strawberry: return .red
        case .banana: return .yellow
        case .mango: return .orange
        case .kiwi: return .green
        case .blueberry: return .blue
        }
    }
}

struct Order: Identifiable, Equatable {
    let id = UUID()
    let fruits: [Fruit]
    let reward: Int

    var recipeText: String {
        fruits.map(\.emoji).joined()
    }
}

enum DayPhase {
    case idle
    case preparing
    case feedback(String)
    case dayEnd
}

@MainActor
final class DayEngine: ObservableObject {
    static let blenderCapacity = 5
    static let ordersPerDay = 5

    @Published var day = 1
    @Published var score = 0
    @Published var dayScore = 0
    @Published var servedCount = 0
    @Published var lostCount = 0
    @Published var currentOrder: Order?
    @Published var blender: [Fruit] = []
    @Published var phase: DayPhase = .idle
    @Published var remainingPatience: TimeInterval = 0
    @Published var patienceDuration: TimeInterval = 1

    private var feedbackTask: Task<Void, Never>?
    private var patienceTask: Task<Void, Never>?

    func startDay() {
        servedCount = 0
        lostCount = 0
        dayScore = 0
        nextCustomer()
    }

    func nextCustomer() {
        blender = []
        let order = Self.randomOrder()
        currentOrder = order
        patienceDuration = Self.patienceSeconds(fruitCount: order.fruits.count, day: day)
        remainingPatience = patienceDuration
        phase = .preparing
        startPatienceTimer()
    }

    func addFruit(_ fruit: Fruit) {
        guard blender.count < Self.blenderCapacity else { return }
        blender.append(fruit)
    }

    func removeFruit(at index: Int) {
        guard blender.indices.contains(index) else { return }
        blender.remove(at: index)
    }

    func serve() {
        guard let order = currentOrder else { return }
        stopPatienceTimer()
        let earned = Self.score(order: order, blender: blender)
        score += earned
        dayScore += earned
        servedCount += 1
        blender = []
        currentOrder = nil
        advanceAfterFeedback("+\(earned) puan")
    }

    private func advanceAfterFeedback(_ message: String) {
        if servedCount >= Self.ordersPerDay {
            phase = .dayEnd
        } else {
            phase = .feedback(message)
            feedbackTask?.cancel()
            feedbackTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                self?.nextCustomer()
            }
        }
    }

    private func customerLeft() {
        stopPatienceTimer()
        lostCount += 1
        servedCount += 1
        blender = []
        currentOrder = nil
        advanceAfterFeedback("Müşteri kaçtı 🏃")
    }

    func advanceDay() {
        day += 1
        startDay()
    }

    private func startPatienceTimer() {
        patienceTask?.cancel()
        patienceTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(100))
                guard let self, !Task.isCancelled else { return }
                if self.remainingPatience <= 0.1 {
                    self.customerLeft()
                    return
                }
                self.remainingPatience -= 0.1
            }
        }
    }

    private func stopPatienceTimer() {
        patienceTask?.cancel()
        remainingPatience = 0
    }

    static func patienceSeconds(fruitCount: Int, day: Int) -> TimeInterval {
        let base = 10.0 + Double(fruitCount) * 2.0
        let difficulty = max(0.65, 1.0 - 0.05 * Double(day - 1))
        return (base * difficulty).rounded(.up)
    }

    static func randomOrder() -> Order {
        let count = Int.random(in: 2...4)
        let fruits = (0..<count).map { _ in Fruit.allCases.randomElement()! }
        return Order(fruits: fruits, reward: fruits.count * 20)
    }

    static func score(order: Order, blender: [Fruit]) -> Int {
        let wanted = Dictionary(grouping: order.fruits, by: \.self).mapValues(\.count)
        let got = Dictionary(grouping: blender, by: \.self).mapValues(\.count)
        let correct = wanted.reduce(0) { acc, pair in
            acc + min(pair.value, got[pair.key, default: 0])
        }
        let extra = blender.count - correct
        let base = correct * 20
        let penalty = extra * 5
        let bonus = (order.fruits.count == correct && extra == 0) ? 30 : 0
        return max(0, base - penalty + bonus)
    }
}
