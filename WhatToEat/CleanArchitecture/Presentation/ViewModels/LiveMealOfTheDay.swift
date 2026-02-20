import Foundation

struct LiveMealOfTheDay: AsyncSequence {

    private let intervalNanoseconds: UInt64
    private let maxRequests: Int
    private let fetch: () async -> Meal?

    init(
        intervalSeconds: UInt64,
        maxRequests: Int,
        fetch: @escaping () async -> Meal?
    ) {
        self.intervalNanoseconds = intervalSeconds * 1_000_000_000
        self.maxRequests = maxRequests
        self.fetch = fetch
    }

    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(
            intervalNanoseconds: intervalNanoseconds,
            maxRequests: maxRequests,
            fetch: fetch
        )
    }

    struct AsyncIterator: AsyncIteratorProtocol {
        private let intervalNanoseconds: UInt64
        private var remainingRequests: Int
        private var isFirstRequest = true
        private let fetch: () async -> Meal?

        init(
            intervalNanoseconds: UInt64,
            maxRequests: Int,
            fetch: @escaping () async -> Meal?
        ) {
            self.intervalNanoseconds = intervalNanoseconds
            self.remainingRequests = maxRequests
            self.fetch = fetch
        }

        mutating func next() async -> Meal? {
            while remainingRequests > 0 {
                if !isFirstRequest {
                    try? await Task.sleep(nanoseconds: intervalNanoseconds)
                }
                isFirstRequest = false

                remainingRequests -= 1

                if let meal = await fetch() {
                    return meal
                }
            }

            return nil
        }
    }
}
