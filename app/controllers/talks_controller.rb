class TalksController < BaseController

  before_action :set_talk, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :redirect_if_low_on_credits, only: :new

  # GET /talks/featured
  def featured
    @talks = Talk.prelive.featured.paginate(page: params[:page], per_page: 25)
    render :index
  end

  # GET /talks/upcoming
  def upcoming
    @talks = Talk.prelive.ordered.paginate(page: params[:page], per_page: 25)
    render :index
  end

  # GET /talks/popular
  def popular
    @talks = Talk.popular.paginate(page: params[:page], per_page: 25)
    render :index
  end

  # GET /talks/live
  def live
    @talks = Talk.live_and_halflive.paginate(page: params[:page], per_page: 25)
    render :index
  end

  # GET /talks/recent
  def recent
    @talks = Talk.recent.paginate(page: params[:page], per_page: 25)
    render :index
  end

  def index
    @talks_live     = Talk.live.limit(5)
    @talks_featured = Talk.featured.limit(5)
    @talks_recent   = Talk.recent.limit(5)
    @talks_popular  = Talk.popular.limit(5)
  end

  # GET /talks/1
  def show
    respond_to do |format|
      @related_talks = @talk.related_talks
      format.html do
        # write to session to make sure we have an id
        # see http://stackoverflow.com/questions/13673969
        session[:foo] = 'bar'
        session_id = session[:session_id]
        RegisterListenerMessage.call(@talk, session_id)
      end
      format.text do
        authorize! :manage, @talk
        render text: @talk.message_history
      end
      format.png { send_file @talk.flyer.path(true) }
      format.ics
    end
  end

  # GET /talks/new
  def new
    attrs = params[:talk] ? talk_params : {}
    attrs[:venue_id] ||= current_user.default_venue_id
    @talk = Talk.new(attrs)
    authorize! :new, @talk
  end

  # GET /talks/1/edit
  def edit
  end

  # POST /talks
  def create
    @talk = Talk.new(talk_params)

    # TODO explain, doesn't that mean i can steal someone's venue by
    # creating a talk?
    @talk.venue_user = current_user

    authorize! :create, @talk

    if @talk.save
      redirect_to @talk, notice: 'Talk was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /talks/1
  def update

    # TODO same concern here, see above
    # set venue_user to be able to create series on the fly while
    # updating talks
    @talk.venue_user = current_user

    authorize! :update, @talk
    if @talk.update(talk_params)
      redirect_to @talk, notice: 'Talk was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /talks/1
  def destroy
    authorize! :destroy, @talk

    @talk.destroy
    redirect_to current_user, notice: 'Talk was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_talk
    @talk = Talk.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def talk_params
    params.require(:talk).permit(:title, :teaser, :starts_at_date,
                                 :starts_at_time, :duration,
                                 :description, :collect, :image,
                                 :tag_list, :guest_list, :language,
                                 :format, :new_venue_title, :venue_id,
                                 :user_override_uuid, :dryrun)
  end

end
