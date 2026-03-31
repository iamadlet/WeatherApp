struct ForecastResponse: Decodable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ForecastItemResponse]
    let city: CityResponse
}
