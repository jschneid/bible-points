require 'test_helper'

class HomepageControllerTest < ActionDispatch::IntegrationTest
  def test_success
    get root_path
    assert_response :ok
    assert_select 'h1', 'Bible Points'
  end

end
