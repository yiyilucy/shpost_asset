class LvcDiscardLvcDiscardDetailController < ApplicationController
  load_and_authorize_resource :lvc_discard
  load_and_authorize_resource :lvc_discard_detail, through: :lvc_discard, parent: false

  def index
    # binding.pry
    @atype = params[:atype]
    @lvc_discard_details_grid = initialize_grid(@lvc_discard_details,
      :order => 'lvc_discard_details.low_value_consumption_info_id',
      :order_direction => 'asc', per_page: 50)
  end

  private

  def set_relationship
    @lvc_discard_detail = LvcDiscardDetail.find(params[:id])
  end

  def low_value_consumption_info_params
    params.require(:lvc_discard_detail).permit(:lvc_catalog_id, :low_value_consumption_info_id)
  end

end