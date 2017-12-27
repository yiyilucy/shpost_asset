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

RSpec.describe LvcDiscardDetailsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # LvcDiscardDetail. As you add validations to LvcDiscardDetail, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # LvcDiscardDetailsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all lvc_discard_details as @lvc_discard_details" do
      lvc_discard_detail = LvcDiscardDetail.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:lvc_discard_details)).to eq([lvc_discard_detail])
    end
  end

  describe "GET #show" do
    it "assigns the requested lvc_discard_detail as @lvc_discard_detail" do
      lvc_discard_detail = LvcDiscardDetail.create! valid_attributes
      get :show, {:id => lvc_discard_detail.to_param}, valid_session
      expect(assigns(:lvc_discard_detail)).to eq(lvc_discard_detail)
    end
  end

  describe "GET #new" do
    it "assigns a new lvc_discard_detail as @lvc_discard_detail" do
      get :new, {}, valid_session
      expect(assigns(:lvc_discard_detail)).to be_a_new(LvcDiscardDetail)
    end
  end

  describe "GET #edit" do
    it "assigns the requested lvc_discard_detail as @lvc_discard_detail" do
      lvc_discard_detail = LvcDiscardDetail.create! valid_attributes
      get :edit, {:id => lvc_discard_detail.to_param}, valid_session
      expect(assigns(:lvc_discard_detail)).to eq(lvc_discard_detail)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new LvcDiscardDetail" do
        expect {
          post :create, {:lvc_discard_detail => valid_attributes}, valid_session
        }.to change(LvcDiscardDetail, :count).by(1)
      end

      it "assigns a newly created lvc_discard_detail as @lvc_discard_detail" do
        post :create, {:lvc_discard_detail => valid_attributes}, valid_session
        expect(assigns(:lvc_discard_detail)).to be_a(LvcDiscardDetail)
        expect(assigns(:lvc_discard_detail)).to be_persisted
      end

      it "redirects to the created lvc_discard_detail" do
        post :create, {:lvc_discard_detail => valid_attributes}, valid_session
        expect(response).to redirect_to(LvcDiscardDetail.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved lvc_discard_detail as @lvc_discard_detail" do
        post :create, {:lvc_discard_detail => invalid_attributes}, valid_session
        expect(assigns(:lvc_discard_detail)).to be_a_new(LvcDiscardDetail)
      end

      it "re-renders the 'new' template" do
        post :create, {:lvc_discard_detail => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested lvc_discard_detail" do
        lvc_discard_detail = LvcDiscardDetail.create! valid_attributes
        put :update, {:id => lvc_discard_detail.to_param, :lvc_discard_detail => new_attributes}, valid_session
        lvc_discard_detail.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested lvc_discard_detail as @lvc_discard_detail" do
        lvc_discard_detail = LvcDiscardDetail.create! valid_attributes
        put :update, {:id => lvc_discard_detail.to_param, :lvc_discard_detail => valid_attributes}, valid_session
        expect(assigns(:lvc_discard_detail)).to eq(lvc_discard_detail)
      end

      it "redirects to the lvc_discard_detail" do
        lvc_discard_detail = LvcDiscardDetail.create! valid_attributes
        put :update, {:id => lvc_discard_detail.to_param, :lvc_discard_detail => valid_attributes}, valid_session
        expect(response).to redirect_to(lvc_discard_detail)
      end
    end

    context "with invalid params" do
      it "assigns the lvc_discard_detail as @lvc_discard_detail" do
        lvc_discard_detail = LvcDiscardDetail.create! valid_attributes
        put :update, {:id => lvc_discard_detail.to_param, :lvc_discard_detail => invalid_attributes}, valid_session
        expect(assigns(:lvc_discard_detail)).to eq(lvc_discard_detail)
      end

      it "re-renders the 'edit' template" do
        lvc_discard_detail = LvcDiscardDetail.create! valid_attributes
        put :update, {:id => lvc_discard_detail.to_param, :lvc_discard_detail => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested lvc_discard_detail" do
      lvc_discard_detail = LvcDiscardDetail.create! valid_attributes
      expect {
        delete :destroy, {:id => lvc_discard_detail.to_param}, valid_session
      }.to change(LvcDiscardDetail, :count).by(-1)
    end

    it "redirects to the lvc_discard_details list" do
      lvc_discard_detail = LvcDiscardDetail.create! valid_attributes
      delete :destroy, {:id => lvc_discard_detail.to_param}, valid_session
      expect(response).to redirect_to(lvc_discard_details_url)
    end
  end

end
