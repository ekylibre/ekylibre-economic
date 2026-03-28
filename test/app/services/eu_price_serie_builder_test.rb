require 'test_helper'

class EuPriceSerieBuilderTest < Minitest::Test
  def test_service
    series = ::EuPriceSerieBuilder.new(harvest_year: 2021, variety: nil, activity_family: 'vine_farming' ).build_series
    assert_equal(8,series.length)
    first_serie = series.first
    expected_serie = {
      name: "Blancs / Vin sans IG avec mention de cépages",
      data: [76.0, 91.0, 131.0, 75.0, nil, 96.5, 83.0, 89.0, 87.0, 88.0, 89.0, 87.0],
      visible: true,
      color: "#1A24F5"
    }
    assert_equal(expected_serie, series.first)
  end
end