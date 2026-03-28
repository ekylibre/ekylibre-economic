require 'bigdecimal'
require 'bigdecimal/util'

class EuPriceSerieBuilder
  SERIE_COLOR = "#1A24F5"

  VARIETY_TO_EU_PRODUCT_CODE = { 'avena_sativa': 'AVO',
    'triticum_aestivum': 'BLTFOUR, BLTPAN',
    'triticum_durum': 'DUR',
    'zea_mays': 'MAI',
    'hordeum_vulgare': 'ORGBRASS, ORGFOUR',
    'secale_cereale': 'SEGPAN, SEGFOUR',
    'x_triticosecale': 'TRI'
  }.freeze
  ACTIVITY_FAMILY_TO_EU_PRODUCT_CATEGORY = { 
    plant_farming: 'cereal',
    vine_farming: 'wine',
  }

  def initialize(activity_family:, harvest_year: , variety:, client: EuropeanCommissionApi::PriceClient.new)
    @harvest_year = harvest_year
    @product_category = ACTIVITY_FAMILY_TO_EU_PRODUCT_CATEGORY.fetch(activity_family.to_sym, nil)
    @product_code = VARIETY_TO_EU_PRODUCT_CODE.fetch(variety.to_sym, nil) if variety
    @begin_date = "01/01/#{(harvest_year-1).to_s}"
    @client = client
  end
  
  def  build_series
    return [] if product_category.nil?

    response = client.get_prices(product_category, begin_date, product_code)
    eu_dataset = response.sort_by { |d| [d[:productName], d[:marketName], d[:weekNumber]] }.group_by do |d|
      if d[:productName]
        [d[:productName], d[:marketName]]
      elsif d[:description]
        d[:description]
      end
    end

    eu_dataset.map do |product, dataset|
      dataset_by_month = dataset.group_by { |data| Date.parse(data[:beginDate]).strftime("%m/%Y") }
      average_price_by_month = months.map do |month|
        dataset_for_month = dataset_by_month.fetch(month, [])
        if dataset_for_month.any?
          (dataset_for_month.sum(0) { |v| v[:price].delete('€').to_d } / dataset_for_month.size.to_f).round(2).to_f
        else
          nil
        end
      end
      {name: product, data: average_price_by_month, visible: true, color: SERIE_COLOR }
    end
  end

  private

    attr_reader :harvest_year, :product_category, :product_code, :begin_date, :client
    
    def months
      (1..12).map { |m| Date.new(harvest_year - 1, m, 1).strftime("%m/%Y") }
    end
end