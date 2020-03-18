class Thing::Cell < Cell::Concept
  include Gemgem::Cell::GridCell
  self.classes = %w[columns large-3]

  include Gemgem::Cell::CreatedAt

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
    link_to name, thing_path(model)
  end
end
