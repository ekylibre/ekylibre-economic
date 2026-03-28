require 'test_helper'

module EuropeanCommissionApi
  class PriceClientTest < Minitest::Test
    def setup
      @client = EuropeanCommissionApi::PriceClient.new
    end
  
    def test_get_cereal_price
      assert_equal([], @client.get_prices('cereal', '01/01/2021', 'AVO'))
    end
  
    def test_get_wine_price
      assert_equal(94, @client.get_prices('wine', '01/01/2022').length)
    end
  end
end
