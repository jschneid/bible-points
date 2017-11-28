require 'test_helper'

class PointsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @point = points(:one)
  end

  def test_show__success
    get point_path 2, 2
    assert_redirected_to edit_point_path(2, 2)
  end

  def test_edit__success
    get edit_point_path @point.book_id, @point.chapter
    assert_response :ok
    assert_select '.point_text', /In the beginning/
    assert_equal 1, @point.book_id
    assert_equal 1, @point.chapter
    assert_equal 'Genesis', assigns(:book).name
  end

  def test_show__book_too_low
    get edit_point_path 0, 1
    assert_equal 'Book not found.', flash[:warning]
    assert_redirected_to edit_point_path 1, 1
  end

  def test_show__book_too_high
    get edit_point_path 67, 1
    assert_equal 'Book not found.', flash[:warning]
    assert_redirected_to edit_point_path 1, 1
  end

  def test_show__book_not_an_integer
    get edit_point_path 'abc', 1
    assert_equal 'Book must be an integer.', flash[:warning]
    assert_redirected_to edit_point_path 1, 1
  end

  def test_show__chapter_too_low
    get edit_point_path 1, 0
    assert_equal 'Genesis does not have a chapter 0.', flash[:warning]
    assert_redirected_to edit_point_path 1, 1
  end

  def test_show__chapter_too_high
    get edit_point_path 2, 41
    assert_equal 'Exodus does not have a chapter 41.', flash[:warning]
    assert_redirected_to edit_point_path 1, 1
  end

  def test_show__book_not_an_integer
    get edit_point_path 1, 'abc'
    assert_equal 'Chapter must be an integer.', flash[:warning]
    assert_redirected_to edit_point_path 1, 1
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
