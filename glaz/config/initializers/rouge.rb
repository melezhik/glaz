require 'rouge/plugins/redcarpet'

class CustomHtml < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet # yep, that's it.
end

