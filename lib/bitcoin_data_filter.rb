require 'date'

Dir['./lib/granularity_filters/*.rb'].each(&method(:require))

class BitcoinDataFilter
  class InvalidFilterError < StandardError
    def initialize(message = 'Filters must be from the list: order_dir, filter_date_from, filter_date_to or granularity')
      super
    end
  end

  class InvalidGranularityFilterError < StandardError
    def initialize(message = 'Granularity must be daily, weekly, monthly or quarterly')
      super
    end
  end

  VALID_FILTERS = %i[order_dir filter_date_from filter_date_to granularity].freeze
  GRANULARITIES = {
    daily: GranularityFilters::Daily,
    weekly: GranularityFilters::Weekly,
    monthly: GranularityFilters::Monthly,
    quarterly: GranularityFilters::Quarterly
  }

  def initialize(data, filters)
    @data = data
    @filters = filters
    @filters[:order_dir] ||= :desc
    @filters[:granularity] ||= :daily
    @filters[:filter_date_to] = Date.parse(@filters[:filter_date_to]) if @filters[:filter_date_to] && !@filters[:filter_date_to].is_a?(Date)
    @filters[:filter_date_from] = Date.parse(@filters[:filter_date_from]) if @filters[:filter_date_from] && !@filters[:filter_date_from].is_a?(Date)

    raise InvalidFilterError unless filters.keys.all? { |filter| VALID_FILTERS.include?(filter) }
  end

  def filter
    filter_date_range

    group_by_granularity

    order_by_date

    @data
  end

  private

  def filter_date_range
    return unless @filters[:filter_date_to] || @filters[:filter_date_from]

    @data.select! do |item|
      if @filters[:filter_date_to] && @filters[:filter_date_from]
        Date.parse(item['date']).between?(@filters[:filter_date_to], @filters[:filter_date_from])
      elsif @filters[:filter_date_from]
        Date.parse(item['date']) >= @filters[:filter_date_from]
      else @filters[:filter_date_to]
        Date.parse(item['date']) <= @filters[:filter_date_to]
      end
    end
  end

  def group_by_granularity
    raise InvalidGranularityFilterError unless GRANULARITIES.keys.include?(@filters[:granularity])

    @data = GRANULARITIES[@filters[:granularity]].new(@data).filter
  end

  def order_by_date
    @data.sort! do |(date, _price), (next_date, _next_price)|
      @filters[:order_dir] == :desc ? Date.parse(next_date) <=> Date.parse(date) : Date.parse(date) <=> Date.parse(next_date)
    end
  end
end
