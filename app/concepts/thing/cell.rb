class Thing::Cell < Cell::Concept
  include ActionView::Helpers::DateHelper
  include Rails::Timeago::Helper

  property :name
  property :created_at

  def show
    render
  end

  class Grid < Cell::Concept
    def show
      things = Thing.latest
      concept('thing/cell', collection: things, last: things.last)
    end
  end

  private

  def name_link
    link_to name, edit_thing_path(model)
  end

  def created_at_ago
    timeago_tag(created_at)
  end

  def classes
    classes = %w[columns large-3]
    classes << 'end' if options[:last] === model
    classes
  end
end
