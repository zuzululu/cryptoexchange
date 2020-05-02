require 'bigdecimal'

module Cryptoexchange::Exchanges
  module Huobi
    module Services
      class Market < Cryptoexchange::Services::Market
        class << self
          def supports_individual_ticker_query?
            true
          end
        end

        def fetch(market_pair)
          output = super(ticker_url(market_pair))
          adapt(output, market_pair)
        end

        def ticker_url(market_pair)
          name = "#{market_pair.base}#{market_pair.target}".downcase
          base = Cryptoexchange::Exchanges::Huobi::Market::DOT_PRO_API_URL

          "#{base}/market/detail/merged?symbol=#{name}"
        end

        def adapt(output, market_pair)
          handle_invalid(output)
          market = output['tick']

          ticker           = Cryptoexchange::Models::Ticker.new
          ticker.base      = market_pair.base
          ticker.target    = market_pair.target
          ticker.market    = Huobi::Market::NAME
          ticker.last      = NumericHelper.to_d(market['close'])
          ticker.bid       = NumericHelper.to_d(market['bid'][0])
          ticker.ask       = NumericHelper.to_d(market['ask'][0])
          ticker.high      = NumericHelper.to_d(market['high'])
          ticker.low       = NumericHelper.to_d(market['low'])
          ticker.volume    = NumericHelper.to_d(market['amount'])
          ticker.timestamp = nil
          ticker.payload   = market
          ticker
        end

        def handle_invalid(output)
          if output['status'] == "error"
            raise Cryptoexchange::ResultParseError, { response: output }
          end
        end
      end
    end
  end
end
