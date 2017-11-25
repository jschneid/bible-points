class PointsController < ApplicationController
  # GET /points/book_id/chapter/edit
  def edit
    @point = Point.find_by(book_id: params[:book_id], chapter: params[:chapter])
    @point = Point.new if @point.nil?
  end

  # POST /points
  def create
    @point = Point.new(point_params)
    if @point.save
      flash[:success] = 'Saved!'
      redirect_to @point
    else
      render :new, status: :bad_request
    end
  end

  # PATCH/PUT /points/1
  def update
    @point = Point.find_by(book_id: params[:book_id], chapter: params[:chapter])
    if @point.update(point_params__edit)
      flash[:success] = 'Updated!'
      redirect_to @point
    else
      render :edit, status: :bad_request
    end
  rescue ActiveRecord::RecordNotFound
    handle_not_found
  end

  private

  def point_params__create
    params.require(:point).permit(:book_id, :chapter, :text)
  end

  def image_params__edit
    params.require(:point).permit(:text)
  end

  def handle_not_found
    flash[:warning] = 'Point not found.'
    redirect_to root_path
  end
end
