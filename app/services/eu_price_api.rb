class EuPriceApi
  # EUROPA API
  # DOC on https://agridata.ec.europa.eu/extensions/DataPortal/API_Documentation.html
  EUROPA_BASE_URL = "https://ec.europa.eu/agrifood"
  EUROPA_PARAMETERS = "?memberStateCodes=FR"
  EUROPA_PRODUCTION_ENDPOINT = { 'cereal' => '/api/cereal/prices',
                                 'wine' => '/api/wine/prices'
                               }.freeze

  EUROPA_PRODUCT_CODE = { 'avena_sativa': 'AVO',
                          'triticum_aestivum': 'BLTFOUR, BLTPAN',
                          'triticum_durum': 'DUR',
                          'zea_mays': 'MAI',
                          'hordeum_vulgare': 'ORGBRASS, ORGFOUR',
                          'secale_cereale': 'SEGPAN, SEGFOUR',
                          'x_triticosecale': 'TRI'
                        }.freeze

  TRANSCODE_EUROPA_UNIT = { 'TONNES' => :ton }.freeze


  def initialize(harvest_year: , variety: , product_category: 'cereals')
    @product_category = product_category
    @base_url = EUROPA_BASE_URL + EUROPA_PRODUCTION_ENDPOINT[product_category] + EUROPA_PARAMETERS
    @product_code = EUROPA_PRODUCT_CODE[variety.to_sym]
    @call_url = @base_url + "&beginDate=01/01/#{harvest_year.to_s}"
  end

  def call
    if @product_code.present? && @product_category == 'cereals'
      begin
        call = RestClient.get @call_url + "&productCodes=#{@product_code}"
      rescue RestClient::ExceptionWithResponse => e
        return []
      end
      if call && call.code == 200
        response = JSON.parse(call.body).map(&:deep_symbolize_keys)
        datasets = response.sort_by { |d| [d[:productName], d[:marketName], d[:weekNumber]] }.group_by { |d| [d[:productName], d[:marketName]] }
      else
        []
      end
    elsif @product_category == 'wines'
      begin
        call = RestClient.get @call_url
      rescue RestClient::ExceptionWithResponse => e
        return []
      end
      if call && call.code == 200
        response = JSON.parse(call.body).map(&:deep_symbolize_keys)
        datasets = response.sort_by { |d| [d[:description], d[:weekNumber]] }.group_by { |d| d[:description] }
      else
        []
      end
    else
      []
    end
  end
end
