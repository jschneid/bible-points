class PointsController < ApplicationController
  # GET /points/book_id/chapter/edit
  def edit
    @point = Point.find_by(book_id: params[:book_id], chapter: params[:chapter])
    @point = Point.new if @point.nil?
  end

  def new
    @point = Point.new if @point.nil?

  end

  # PATCH/PUT /points/
  def update
    @point = Point.find_by(book_id: params[:book_id], chapter: params[:chapter])
    if @point.nil?
      do_create
    else
      do_update
    end

  end

  private

  def point_params__create
    params.require(:point).permit(:book_id, :chapter, :text)
  end

  def point_params__edit
    params.require(:point).permit(:text)
  end

  def do_create
    @point = Point.new(point_params__create)
    if @point.save
      flash[:success] = 'Saved!'
      redirect_to edit_point_path @point.book_id, @point.chapter
    else
      render :edit, status: :bad_request
    end
  end

  def do_update

    Rails.logger.info(@point.errors.messages.inspect)

    if @point.update!(point_params__edit)
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
