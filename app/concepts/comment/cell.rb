class Comment::Cell < Cell::Concept
  include Gemgem::Cell::GridCell
  self.classes = %w[comment large-4 columns]

  include Gemgem::Cell::CreatedAt

  property :created_at
  property :body
  property :user

  class Grid < Cell::Concept
    include Kaminari::Cells
    inherit_views Comment::Cell
    include ActionView::Helpers::JavaScriptHelper

    def show
      # concept('comment/cell', collection: comments).to_s + paginate(comments).html_safe
      render :grid
    end

    def append
      %{
        var el = document.getElementById('next')
        el.outerHTML = "#{j show}"
      }
    end

    private

    def comments
      @comments ||= model.comments.page(page).per(3)
    end

    def page
      options[:page] or 1
    end
  end

  private

  def nice?
    model.weight.zero?
  end
end
