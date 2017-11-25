require 'test_helper'

class PointsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @point = points(:one)
  end

  def test_show__success
    get '/points/1/1/edit'
    assert_response :ok
    assert_select '.point_text', /In the beginning/
    assert_equal 1, @point.book_id
    assert_equal 1, @point.chapter
    assert_equal 'Genesis', assigns(:book_name)
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
    assert_equal 'Updated!', flash[:success]
  end

  def test_update__create_success
    point_params = { book_id: 66, chapter: 22, text: 'Revised text' }
    assert_difference('Point.count', 1) do
      patch point_path(point_params[:book_id], point_params[:chapter]), params: { point: point_params }
    end

    assert_redirected_to edit_point_path(point_params[:book_id], point_params[:chapter])
    new_point = Point.find_by(book_id: point_params[:book_id], chapter: point_params[:chapter])
    assert_equal 'Revised text', new_point.text
    assert_equal 'Saved!', flash[:success]
  end

end
