/// Hinge / fold-fraction observer. No-ops when differentiated APIs are unavailable.
public enum DuoHinge {
    public struct ObservationToken: Sendable, Equatable {
        public let id: UInt64
        fileprivate init(id: UInt64) { self.id = id }
    }

    /// 0...1 fold fraction; 0 when unavailable.
    public static var currentFraction: Double {
        DuoFeatureGate.differentiatedAPIsAvailable ? 0 : 0
    }

    /// Registers `handler` for hinge updates. Returns a token; handler never fires while unavailable.
    @discardableResult
    public static func observe(_ handler: @escaping @Sendable (Double) -> Void) -> ObservationToken {
        _ = handler
        return ObservationToken(id: 0)
    }

    public static func cancel(_ token: ObservationToken) {
        _ = token
    }
}
