require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe SeriesController do

  before  do
    @user = FactoryGirl.create(:user)
    allow(request.env['warden']).to receive_messages :authenticate! => @user
    allow(controller).to receive_messages :current_user => @user
    @user.reload
  end

  def valid_attributes
    FactoryGirl.attributes_for(:series)
  end

  def invalid_attributes
    { asdf: 'asdf' }
  end

  def valid_session
    {}
  end

  describe "GET show" do
    let(:series) { FactoryGirl.create(:series) }
    it "assigns the requested series as @series when logged in" do
      get :show, {:id => series.to_param}
      expect(assigns(:series)).to eq(series)
    end
    it "returns http success with format rss" do
      get :show, id: series.to_param, format: 'rss'
      expect(response).to be_success
    end
  end

  describe "GET new" do
    it "assigns a new series as @series" do
      get :new, {}
      expect(assigns(:series)).to be_a_new(Series)
    end
  end

  describe "GET edit" do
    it "assigns the requested series as @series when edited by owner" do
      series = FactoryGirl.create(:series, :user => @user)
      get :edit, {:id => series.to_param}, valid_session
      expect(assigns(:series)).to eq(series)
    end
  end

  describe "GET edit" do
    it "redirect to root page if series requested by other user" do
      series = FactoryGirl.create(:series)
      get :edit, {:id => series.to_param}, valid_session
      expect(response.status).to eq(403)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Series" do
        expect {
          post :create, { :series => FactoryGirl.attributes_for(:series) }, valid_session
        }.to change(Series, :count).by(1)
      end

      it "assigns a newly created series as @series" do
        post :create, { :series => FactoryGirl.attributes_for(:series) }, valid_session
        expect(assigns(:series)).to be_a(Series)
        expect(assigns(:series)).to be_persisted
      end

      it "redirects to the created series" do
        post :create, {:series => FactoryGirl.attributes_for(:series) }, valid_session
        expect(response).to redirect_to(Series.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved series as @series" do
        post :create, {series: invalid_attributes}, valid_session
        expect(assigns(:series)).to be_a_new(Series)
      end

      it "re-renders the 'new' template" do
        post :create, {series: invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end

      #it "raises authorization error when person without series_host-role tries to create a series" do
      #  k = FactoryGirl.create(:published_kluuu)
      #  expect {
      #    post :create, { :series => FactoryGirl.attributes_for(:series, :host_kluuu_id => k.id)}, valid_session
      #  }.to raise_error(CanCan::AccessDenied)
      #end
    end
  end
  #
  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested series" do
        series = FactoryGirl.create(:series, user: @user)
        put :update, {id: series.to_param, series: { title: 'blablub' }}, valid_session
        expect(series.reload.title).to eq('blablub')
      end

      it "assigns the requested series as @series" do
        series = FactoryGirl.create(:series, :user => @user)
        put :update, {:id => series.to_param, :series => {:description => "hier einige changes"}}, valid_session
        expect(assigns(:series)).to eq(series)
      end

      it "redirects to the series" do
        series = FactoryGirl.create(:series, :user => @user)
        put :update, {:id => series.to_param, :series => {:description => "noch mehr changes"}}, valid_session
        expect(response).to redirect_to(series)
      end
    end

    describe "with invalid params" do
      it "assigns the series as @series" do
        series = FactoryGirl.create(:series, :user => @user)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Series).to receive(:save).and_return(false)
        put :update, {id: series.to_param, series: invalid_attributes}, valid_session
        expect(assigns(:series)).to eq(series)
      end

      it "re-renders the 'edit' template" do
        series = FactoryGirl.create(:series, :user => @user)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Series).to receive(:save).and_return(false)
        put :update, {id: series.to_param, series: invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end

    describe "with unauthorized user" do
      it "raises permission denied" do
        series = FactoryGirl.create(:series)
        put :update, {id: series.to_param, series: invalid_attributes}, valid_session
        expect(response.status).to eq(403)
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested series" do
      series = FactoryGirl.create(:series, user: @user)
      expect {
        delete :destroy, {:id => series.to_param}, valid_session
      }.to change(Series, :count).by(-1)
    end

    it "redirects to the series list" do
      series = FactoryGirl.create(:series, user: @user)
      delete :destroy, {:id => series.to_param}, valid_session
      expect(response).to redirect_to(user_url(series.user))
    end

    it "raises permission if unauthorized user" do
      series = FactoryGirl.create(:series)
      delete :destroy, {:id => series.to_param}, valid_session
      expect(response.status).to eq(403)
    end
  end

end
