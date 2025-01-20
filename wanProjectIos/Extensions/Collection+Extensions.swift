extension Collection {
    var isNilOrEmpty: Bool {
        return self.isEmpty
    }
}

extension Optional where Wrapped: Collection {
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
} 