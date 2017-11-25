require 'test_helper'

class PointsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @point = points(:one)
  end

  # TODO NEXT $$$: Get this test working. I think there's a problem with the route configuration.
  def test_show__success
    get '/points/1/1'
    assert_response :ok
    assert_select '.point__text', 'In the beginning'
  end

end
