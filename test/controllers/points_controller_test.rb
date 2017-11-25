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

  def test_points_path
    get edit_point_path @point.book_id, @point.chapter
    assert_response :ok
    assert_select '.point_text', /In the beginning/
  end

  def test_update__edit_success
    point_params = { text: 'Revised text' }
    patch point_path(@point.book_id, @point.chapter), params: { point: point_params }
    assert_redirected_to edit_point_path(@point.book_id, @point.chapter)
    updated_point = Point.find_by(book_id: @point.book_id, chapter: @point.chapter)
    assert_equal 'Revised text', updated_point.text
  end

  def test_update__create_success
    assert_difference('Point.count', 1) do
      image_params = { text: 'Revised text' }
      patch points_path, params: { point: points_params }
    end

    assert_redirected_to image_url(Image.last)
  end

end
