require 'faye'

Faye::WebSocket.load_adapter('puma')
bayeux = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25)
run bayeux
