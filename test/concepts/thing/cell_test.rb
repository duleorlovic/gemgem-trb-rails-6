class ThingCellTest < Cell::TestCase
  include ActionDispatch::TestProcess # for fixture_file_upload
  controller ThingsController

  test 'success' do
    Thing.delete_all
    result = Thing::Operation::Create.(params: {thing: {name: 'Trailblazer'}})
    assert result.success?
    result = Thing::Operation::Create.(params: {thing: {name: 'Rails'}})
    assert result.success?

    node = concept('thing/cell/grid').to_s
    assert node.has_selector?('.columns .header a', text: 'Rails')
    refute node.has_selector?('.columns.end .header a', text: 'Rails')
    assert node.has_selector?('.columns.end .header a', text: 'Trailblazer')
  end

  test 'Cell::Decorator' do
    thing = Thing::Operation::Create.(params: {thing: {name: 'Trailblazer', file: fixture_file_upload('test/fixtures/data/logo.png')}})[:model]
    _node = concept('thing/cell/decorator', thing).(:thumb)
    # assert_equal '<img class="th" src="/images/thumb-cells.jpg" alt="Thumb cells" />', node.to_s
  end
end
