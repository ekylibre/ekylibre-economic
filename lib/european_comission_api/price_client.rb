require 'json'
require 'rest-client'

module EuropeanCommissionApi
  class PriceClient
    BASE_URL = "https://ec.europa.eu/agrifood"
    PRODUCTION_ENDPOINT = { 
      'cereal' => '/api/cereal/prices',
      'wine' => '/api/wine/prices'
    }.freeze
    PRODUCT_CODE = %w(AVO BLTFOUR BLTPAN DUR MAI ORGBRASS ORGFOUR SEGPAN SEGFOUR TRI).freeze
    DEFAULT_PARAMS = {
      'memberStateCodes' => "FR"
    }.freeze

    def get_prices(type, begin_date, product_codes=nil)

      params = {}.merge(DEFAULT_PARAMS)
      params['beginDate'] = begin_date if begin_date
      params['productCodes'] = product_codes if product_codes
      url = BASE_URL + production_end_point(type) + '?' + params.to_query
      get_request(url)
    end

    private

      def production_end_point(type)
        PRODUCTION_ENDPOINT.fetch(type) { raise "Unknown production type #{type}" }
      end

      def get_request(url)
        begin
          call = RestClient.get url
        rescue RestClient::ExceptionWithResponse => e
          return []
        end
        if call && call.code == 200
          response = JSON.parse(call.body).map(&:symbolize_keys!)
        else
          []
        end
      end
  end
end