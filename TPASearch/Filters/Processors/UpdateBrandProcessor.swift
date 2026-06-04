final class UpdateBrandProcessor: SearchFilterEventProcessor<SearchFilterEvents.BrandDidUpdate> {
    override func update(_ query: inout SearchQuery, for event: SearchFilterEvents.BrandDidUpdate) {
        query.brand = event.brand
    }
}
