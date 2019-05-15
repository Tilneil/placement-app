# frozen_string_literal: true

class PlacementsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin, only: %i(new edit)

  require 'roo'

  def new
    @placement = Placement.new
    @licensees = Licensee.all
    @services = Service.all
  end

  def create
    Placement.create(placement_params)
    redirect_to admins_path
  end

  def index
    if params[:query].present?
      @licensees = Licensee.all
      @placements = Placement.search_for(params[:query])
    else
      @licensees = Licensee.all
      @placements = Placement.all
    end
  end

  def show
    @placement = Placement.find(params[:id])
    @licensee = Licensee.find(@placement.licensee_id)
    @comment = Comment.new(placement_id: @placement.id)
    @comments = @placement.comments.collect
  end

  def edit
    @placement = Placement.find(params[:id])
    @licensees = Licensee.all
    session[:return_to] ||= request.referer #this and the redirect in the update
    # action redirect you back to the previous page after you update a placement
  end

  def update
    @placement = Placement.find(params[:id])

    @placement.update!(placement_params)
    if session[:return_to] != nil
      redirect_to session.delete(:return_to)
    else
      redirect_to root_path
    end
  end

  def destroy
    @placement = Placement.find(params[:id])
    @placement.destroy
    redirect_to placements_path
  end

  def comment
    @comment = Comment.new
  end

  private

    def placement_params
     params.require(:placement).permit(:name, :address, :city, :state, :zip,
                                      :county, :phone, :licensee_id, :gender,
                                      :beds, :search)
    end
end
