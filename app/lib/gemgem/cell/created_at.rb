module Gemgem::Cell
  module CreatedAt
    def self.included(base)
      base.send :include, ActionView::Helpers::DateHelper
      base.send :include, Rails::Timeago::Helper
    end

    private

    def created_at_ago
      timeago_tag(created_at)
    end
  end
end
