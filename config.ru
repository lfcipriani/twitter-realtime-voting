$stdout.sync = true
require './web'
require './socket'
Faye::WebSocket.load_adapter('thin')

use TwitterVoting::WebSocket

run TwitterVoting::Dashboard
