struct SavedCityViewModel {
    let id: String
    let name: String
    let coordinates: Coordinates
    var weather: SavedCityWeather?
    var isCurrentLocation: Bool
}
