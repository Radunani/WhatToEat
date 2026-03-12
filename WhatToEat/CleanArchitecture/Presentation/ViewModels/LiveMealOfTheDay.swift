import Foundation

// Simulates a live feed by periodically fetching random meals.
// This is intentionally not a real-time backend stream.
struct LiveMealOfTheDay: AsyncSequence {

    private let interval: Duration
    private let maxRequests: Int
    private let fetch: @MainActor () async -> Meal?

    init(
        intervalSeconds: UInt64,
        maxRequests: Int,
        fetch: @escaping @MainActor () async -> Meal?
    ) {
        self.interval = .seconds(intervalSeconds)
        self.maxRequests = maxRequests
        self.fetch = fetch
    }

    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(
            interval: interval,
            maxRequests: maxRequests,
            fetch: fetch
        )
    }

    struct AsyncIterator: AsyncIteratorProtocol {
        private let interval: Duration
        private var remainingRequests: Int
        private var isFirstRequest = true
        private let fetch: @MainActor () async -> Meal?

        init(
            interval: Duration,
            maxRequests: Int,
            fetch: @escaping @MainActor () async -> Meal?
        ) {
            self.interval = interval
            self.remainingRequests = maxRequests
            self.fetch = fetch
        }

        mutating func next() async -> Meal? {
            while remainingRequests > 0 {
                // First value is emitted immediately, then we delay between updates.
                if !isFirstRequest {
                    try? await Task.sleep(for: interval)
                }
                isFirstRequest = false

                remainingRequests -= 1

                // Each successful fetch represents one simulated "live update" event.
                if let meal = await fetch() {
                    return meal
                }
            }

            return nil
        }
    }
}
