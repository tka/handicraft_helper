require 'action_view'
require 'handicraft/helper'

module HandicraftHelper
end

ActionView::Base.send :include, Handicraft::Helper
