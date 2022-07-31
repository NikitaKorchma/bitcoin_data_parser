require 'oj'
require 'net/http'
require './lib/bitcoin_data_filter'

class BitcoinDataParser
  URL = 'https://pkgstore.datahub.io/cryptocurrency/bitcoin/bitcoin_json/data/3d47ebaea5707774cb076c9cd2e0ce8c/bitcoin_json.json'.freeze

  def initialize(filters = {})
    @filters = filters
  end

  def parse
    load_data

    filter_data

    @data
  end

  private

  def load_data
    uri = URI.parse(URL)
    response = Net::HTTP.get_response(uri)
    @data = Oj.load(response.body)
  end

  def filter_data
    @data = BitcoinDataFilter.new(@data, @filters).filter
  end
end
