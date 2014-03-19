class UsersController < ApplicationController

  before_filter :authenticate_user!, :only => [:edit,:update,:destroy]

  # layout "application", :only => [:welcome]

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  def show
    @user = User.find(params[:id])
    #if @user.participating_venues.empty? && @user.venues.any?
    #  redirect_to venues_user_url(@user)
    #end
  end

  def no_kluuus
    @user = User.find(params[:id])
    #@kluuus = @user.no_kluuus
    render :template =>  'users/kluuus'
  end

  def kluuus
    @user = User.find(params[:id])
    #@kluuus = @user.kluuus
  end

  def venues
    @user = User.find(params[:id])
    @venues = Venue.of_user(@user)

  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    authorize! :edit, @user
    #render :layout => 'application'
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html do
          redirect_to @user, flash: { notice: I18n.t("flash.actions.create.notice") }
        end
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])
    authorize! :update, @user

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html do
          redirect_to @user, flash: { notice: I18n.t("flash.actions.update.notice") }
        end
        #format.json { head :no_content }
        #format.js
      else
        logger.error("Users#update - ERROR: #{@user.errors.inspect}")
        format.html do
          render :template => 'accounts/edit'
         end
        #format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])

    authorize! :destroy, @user

    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def welcome
    #@klu = current_user.no_kluuus.build(:tag_list => "newcomer")
    @user = current_user
  end
end
