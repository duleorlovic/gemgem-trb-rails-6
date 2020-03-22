class Thing::Cell < Cell::Concept
  include Cell::Caching::Notifications
  include Gemgem::Cell::GridCell
  self.classes = %w[columns large-3]

  include Gemgem::Cell::CreatedAt

  property :name
  property :created_at

  def show
    render
  end

  class Grid < Cell::Concept
    cache :show do
      CacheVersion.for('thing/cell/grid')
    end

    def show
      things = Thing.latest
      concept('thing/cell', collection: things, last: things.last).to_s
    end
  end

  class Decorator < Cell::Concept
    extend Paperdragon::Model::Reader
    processable_reader :image
    property :image_meta_data

    def thumb
      image_tag image[:thumb].url, class: :th if image.exists?
    end
  end

  private

  def name_link
    link_to name, thing_path(model)
  end
end
