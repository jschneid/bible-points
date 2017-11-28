class PointsController < ApplicationController

  before_action :set_variables

  # GET /points/book_id/chapter
  def show
    redirect_to edit_point_path(params[:book_id], params[:chapter])
  end

  # GET /points/book_id/chapter/edit
  def edit
    if @point.nil?
      @point = Point.new if @point.nil?
      @point.book_id = params[:book_id]
      @point.chapter = params[:chapter]
    end
  end

  # PATCH/PUT /points/
  def update
    if @point.nil?
      do_create
    else
      do_update
    end
  end

  private

  def set_variables
    handle_error('Book must be an integer.') and return unless params[:book_id].is_integer?
    handle_error('Chapter must be an integer.') and return unless params[:chapter].is_integer?

    @book = Book.find_by(id: params[:book_id])
    handle_error('Book not found.') and return if @book.nil?

    handle_error(@book.name + ' does not have a chapter ' + params[:chapter] + '.') and return if
      params[:chapter].to_i < 1 || params[:chapter].to_i > @book.chapter_count

    @point = Point.find_by(book_id: params[:book_id], chapter: params[:chapter])
  end

  def handle_error(message)
    flash[:warning] = message
    redirect_to edit_point_path 1, 1
  end

  def point_params
    params.require(:point).permit(:text)
  end

  def do_create
    @point = Point.new(point_params)
    @point.book_id = params[:book_id]
    @point.chapter = params[:chapter]
    if @point.save!
      flash[:success] = 'Saved!'
      redirect_to edit_point_path(@point.book_id, @point.chapter)
    else
      render :edit, status: :bad_request
    end
  end

  def do_update
    if @point.update(point_params)
      flash[:success] = 'Updated!'
      redirect_to edit_point_path @point.book_id, @point.chapter
    else
      render :edit, status: :bad_request
    end
  end

  def handle_not_found
    flash[:warning] = 'Point not found.'
    redirect_to root_path
  end
end
