require "ekylibre-economic/engine"
require "ekylibre-economic/ext_navigation"
require "european_comission_api/price_client.rb"

module EkylibreEconomic
  def self.root
    Pathname.new(File.dirname __dir__)
  end
end
