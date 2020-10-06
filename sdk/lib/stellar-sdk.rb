require "stellar-base"
require_relative "stellar/sdk/version"

module Stellar
  autoload :Account
  autoload :Amount
  autoload :Client

  module Horizon
    extend ActiveSupport::Autoload

    autoload :Problem
    autoload :Result
  end

  autoload :TransactionPage
end
