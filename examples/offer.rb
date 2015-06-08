#!/usr/bin/env ruby

# This is an example of using the higher level "payment" wrapper. Notice
# that we are using KeyPair instead of the raw rbnacl keys and that we need
# not build the entire heirarchy of xdr object manually.
#
# You can see where these helpers are defined in the files underneath /lib,
# which is where we extend the xdrgen generated source files with our higher
# level api.
#
# NOTE: due to the way that sequence number for a new account are set, this
# example is pretty cumbersome to run.  It is only used for illustrative purposes
# of the flow

require 'stellar-base'
require 'faraday'
require 'faraday_middleware'

$server = Faraday.new(url: "http://localhost:39132") do |conn|
  conn.response :json
  conn.adapter Faraday.default_adapter
end

def submit(key, tx)
  hex      = tx.to_envelope(key).to_xdr(:hex)
  response = $server.get('tx', blob: hex)
  p response.body
end

master      = Stellar::KeyPair.from_raw_seed("allmylifemyhearthasbeensearching")
destination = Stellar::KeyPair.from_raw_seed("allmylifemyhearthasbeensearching")

submit master, Stellar::Transaction.payment({
  account:     master,
  destination: destination,
  sequence:    1,
  amount:      [:native, 2000 * Stellar::ONE]
})

# NOTE: after this step, you need to get the sequence number for destination
# Which is based off of the ledger sequence number it was funded in.
gets # pause to get the account's sequence from the hayashi db

destination_sequence = FILL_ME_IN
# destination_sequence = 17179869185

submit destination, Stellar::Transaction.change_trust({
  account:    destination,
  sequence:   destination_sequence,
  line:       [:alphanum, "USD\x00", master],
  limit:      1000
})

submit destination, Stellar::Transaction.change_trust({
  account:    destination,
  sequence:   destination_sequence + 1,
  line:       [:alphanum, "EUR\x00", master],
  limit:      1000
})

submit master, Stellar::Transaction.payment({
  account:     master,
  destination: destination,
  sequence:    destination_sequence + 2,
  amount:      [:alphanum, "USD\x00", master, 1000]
})

submit master, Stellar::Transaction.manage_offer({
  account:    destination,
  sequence:   destination_sequence + 3
  taker_gets: [:alphanum, "USD\x00", usd_gateway],
  taker_pays: [:alphanum, "EUR\x00", eur_gateway],
  amount:     100,
  price:      2.0,
})
