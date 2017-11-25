class PointsController < ApplicationController

  before_action :set_var

  # GET /points/book_id/chapter/edit
  def edit
    if @point.nil?
      @point = Point.new if @point.nil?
      @point.book_id = params[:book_id]
      @point.chapter = params[:chapter]

    end
    @book_name = Book.find_by(id: params[:book_id]).name

  end

  def new
    @point = Point.new if @point.nil?

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

  def set_var
    @point = Point.find_by(book_id: params[:book_id], chapter: params[:chapter])

  end

  def point_params__create
    params.require(:point).permit(:book_id, :chapter, :text)
  end

  def point_params__edit
    params.require(:point).permit(:text)
  end

  def do_create
    @point = Point.new(point_params__create)
    if @point.save!
      flash[:success] = 'Saved!'
      redirect_to edit_point_path @point.book_id, @point.chapter
    else
      render :edit, status: :bad_request
    end
  end

  def do_update
    if @point.update(point_params__edit)
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
