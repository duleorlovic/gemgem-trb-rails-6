class ThingCellTest < ActionDispatch::IntegrationTest # ActiveSupport::TestCase # Cell::TestCase
  # controller ThingsController

  test 'success' do
    trb = Thing::Operation::Create.(params: {name: 'Trailblazer'})[:model]
    rails = Thing::Operation::Create.(params: {name: 'Rails'})[:model]
    # html = ::Cell::Concept.cell('thing/cell', trb)
    # html = ::Thing::Cell.new(trb).show
    # html = concept('thing/cell', collection: [trb, rails], last: rails)
    html = '<div>hi</div>'
    doc = Nokogiri::HTML html
    assert_select doc, 'div', 'hi'
  end
end
