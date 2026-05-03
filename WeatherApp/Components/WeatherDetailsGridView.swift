import UIKit
import SnapKit

final class WeatherDetailsGridView: UIView {
    
    private let mainStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
    }
    
    func configure(with model: WeatherDetailsModel) {
        mainStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Ряд 1: В среднем + Ощущается как
        let row1 = createRow(
            left: makeAverageCard(model: model),
            right: makeFeelsLikeCard(model: model)
        )
        mainStack.addArrangedSubview(row1)
        
        // Ряд 2: Ветер (полная ширина)
        let windCard = WindCardView()
        windCard.configure(
            wind: model.windSpeed,
            gusts: model.windGust,
            direction: model.windDirection
        )
        mainStack.addArrangedSubview(windCard)
        
        // Ряд 3: УФ-индекс + Закат
        let row3 = createRow(
            left: makeUVCard(model: model),
            right: makeSunsetCard(model: model)
        )
        mainStack.addArrangedSubview(row3)
        
        // Ряд 4: Влажность + Давление
        let row4 = createRow(
            left: makeHumidityCard(model: model),
            right: makePressureCard(model: model)
        )
        mainStack.addArrangedSubview(row4)
    }
    
    // MARK: - Grid Helper
    
    private func createRow(left: UIView, right: UIView) -> UIStackView {
        let row = UIStackView(arrangedSubviews: [left, right])
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually
        
        // Квадратные карточки
        left.snp.makeConstraints { make in
            make.height.equalTo(left.snp.width)
        }
        
        return row
    }
    
    // MARK: - Card Factories
    
    private func makeAverageCard(model: WeatherDetailsModel) -> WeatherInfoCardView {
        let card = WeatherInfoCardView()
        card.configure(
            icon: "graph",
            title: "On average",
            value: model.avgValue,
            description: model.avgDescription,
            footer: model.avgFooter
        )
        return card
    }
    
    private func makeFeelsLikeCard(model: WeatherDetailsModel) -> WeatherInfoCardView {
        let card = WeatherInfoCardView()
        card.configure(
            icon: "thermometer",
            title: "Feels like",
            value: model.feelsLike,
            footer: model.feelsLikeFooter
        )
        return card
    }
    
    private func makeUVCard(model: WeatherDetailsModel) -> WeatherInfoCardView {
        let card = WeatherInfoCardView()
        card.configure(
            icon: "sunIcon",
            title: "UV index",
            value: "\(model.uvIndexValue)",
            description: model.uvLevel,
            footer: model.uvDescription
        )
        
        let scale = UVScaleView()
        scale.configure(uvIndex: CGFloat(model.uvIndexValue))
        card.addCustomContent(scale)
        
        return card
    }
    
    private func makeSunsetCard(model: WeatherDetailsModel) -> WeatherInfoCardView {
        let card = WeatherInfoCardView()
        card.configure(
            icon: "sunsetIcon",
            title: "Sunset",
            value: model.sunsetTime,
            footer: "Sunrise at \(model.sunriseTime)."
        )
        return card
    }
    
    private func makeHumidityCard(model: WeatherDetailsModel) -> WeatherInfoCardView {
        let card = WeatherInfoCardView()
        card.configure(
            icon: "humidity",
            title: "Humidity",
            value: model.humidity,
            footer: model.humidityDescription
        )
        return card
    }
    
    private func makePressureCard(model: WeatherDetailsModel) -> WeatherInfoCardView {
        let card = WeatherInfoCardView()
        card.configure(
            icon: "pressure",
            title: "Pressure",
            value: model.pressureValue,
            footer: model.pressureFooter
        )
        return card
    }
}
