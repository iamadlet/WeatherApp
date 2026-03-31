struct WindResponse: Decodable {
    let speed: Double
    let deg: Int
    let gust: Double?
}
