require 'test_helper'

class PointsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @point = points(:one)
  end

  def test_show__success
    get '/points/1/1/edit'
    assert_response :ok
    assert_select '.point_text', /In the beginning/
  end

end
