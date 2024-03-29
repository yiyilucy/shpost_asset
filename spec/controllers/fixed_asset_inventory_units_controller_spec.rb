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

RSpec.describe FixedAssetInventoryUnitsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # FixedAssetInventoryUnit. As you add validations to FixedAssetInventoryUnit, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # FixedAssetInventoryUnitsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all fixed_asset_inventory_units as @fixed_asset_inventory_units" do
      fixed_asset_inventory_unit = FixedAssetInventoryUnit.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:fixed_asset_inventory_units)).to eq([fixed_asset_inventory_unit])
    end
  end

  describe "GET #show" do
    it "assigns the requested fixed_asset_inventory_unit as @fixed_asset_inventory_unit" do
      fixed_asset_inventory_unit = FixedAssetInventoryUnit.create! valid_attributes
      get :show, {:id => fixed_asset_inventory_unit.to_param}, valid_session
      expect(assigns(:fixed_asset_inventory_unit)).to eq(fixed_asset_inventory_unit)
    end
  end

  describe "GET #new" do
    it "assigns a new fixed_asset_inventory_unit as @fixed_asset_inventory_unit" do
      get :new, {}, valid_session
      expect(assigns(:fixed_asset_inventory_unit)).to be_a_new(FixedAssetInventoryUnit)
    end
  end

  describe "GET #edit" do
    it "assigns the requested fixed_asset_inventory_unit as @fixed_asset_inventory_unit" do
      fixed_asset_inventory_unit = FixedAssetInventoryUnit.create! valid_attributes
      get :edit, {:id => fixed_asset_inventory_unit.to_param}, valid_session
      expect(assigns(:fixed_asset_inventory_unit)).to eq(fixed_asset_inventory_unit)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new FixedAssetInventoryUnit" do
        expect {
          post :create, {:fixed_asset_inventory_unit => valid_attributes}, valid_session
        }.to change(FixedAssetInventoryUnit, :count).by(1)
      end

      it "assigns a newly created fixed_asset_inventory_unit as @fixed_asset_inventory_unit" do
        post :create, {:fixed_asset_inventory_unit => valid_attributes}, valid_session
        expect(assigns(:fixed_asset_inventory_unit)).to be_a(FixedAssetInventoryUnit)
        expect(assigns(:fixed_asset_inventory_unit)).to be_persisted
      end

      it "redirects to the created fixed_asset_inventory_unit" do
        post :create, {:fixed_asset_inventory_unit => valid_attributes}, valid_session
        expect(response).to redirect_to(FixedAssetInventoryUnit.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved fixed_asset_inventory_unit as @fixed_asset_inventory_unit" do
        post :create, {:fixed_asset_inventory_unit => invalid_attributes}, valid_session
        expect(assigns(:fixed_asset_inventory_unit)).to be_a_new(FixedAssetInventoryUnit)
      end

      it "re-renders the 'new' template" do
        post :create, {:fixed_asset_inventory_unit => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested fixed_asset_inventory_unit" do
        fixed_asset_inventory_unit = FixedAssetInventoryUnit.create! valid_attributes
        put :update, {:id => fixed_asset_inventory_unit.to_param, :fixed_asset_inventory_unit => new_attributes}, valid_session
        fixed_asset_inventory_unit.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested fixed_asset_inventory_unit as @fixed_asset_inventory_unit" do
        fixed_asset_inventory_unit = FixedAssetInventoryUnit.create! valid_attributes
        put :update, {:id => fixed_asset_inventory_unit.to_param, :fixed_asset_inventory_unit => valid_attributes}, valid_session
        expect(assigns(:fixed_asset_inventory_unit)).to eq(fixed_asset_inventory_unit)
      end

      it "redirects to the fixed_asset_inventory_unit" do
        fixed_asset_inventory_unit = FixedAssetInventoryUnit.create! valid_attributes
        put :update, {:id => fixed_asset_inventory_unit.to_param, :fixed_asset_inventory_unit => valid_attributes}, valid_session
        expect(response).to redirect_to(fixed_asset_inventory_unit)
      end
    end

    context "with invalid params" do
      it "assigns the fixed_asset_inventory_unit as @fixed_asset_inventory_unit" do
        fixed_asset_inventory_unit = FixedAssetInventoryUnit.create! valid_attributes
        put :update, {:id => fixed_asset_inventory_unit.to_param, :fixed_asset_inventory_unit => invalid_attributes}, valid_session
        expect(assigns(:fixed_asset_inventory_unit)).to eq(fixed_asset_inventory_unit)
      end

      it "re-renders the 'edit' template" do
        fixed_asset_inventory_unit = FixedAssetInventoryUnit.create! valid_attributes
        put :update, {:id => fixed_asset_inventory_unit.to_param, :fixed_asset_inventory_unit => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested fixed_asset_inventory_unit" do
      fixed_asset_inventory_unit = FixedAssetInventoryUnit.create! valid_attributes
      expect {
        delete :destroy, {:id => fixed_asset_inventory_unit.to_param}, valid_session
      }.to change(FixedAssetInventoryUnit, :count).by(-1)
    end

    it "redirects to the fixed_asset_inventory_units list" do
      fixed_asset_inventory_unit = FixedAssetInventoryUnit.create! valid_attributes
      delete :destroy, {:id => fixed_asset_inventory_unit.to_param}, valid_session
      expect(response).to redirect_to(fixed_asset_inventory_units_url)
    end
  end

end
