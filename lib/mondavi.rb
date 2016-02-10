# require 'celluloid'

# if (Celluloid.group_class != Celluloid::Group::Pool)
#   Celluloid.group_class = Celluloid::Group::Pool
#   Celluloid.init
# end

# Kernel::silence_warnings { Imprint::Tracer.const_set('TRACER_HEADER', 'HTTP_X_B3_TRACEID') }




# require external dependencies
require "tannin/operation"

module Mondavi
  # Your code goes here...
end

# require mondavi files
require "mondavi/version"
require "mondavi/api"
require "mondavi/is_component_local"
require "mondavi/pact_router"
require "mondavi/request_router"
require "mondavi/version"
