class UnitSequencesController < ApplicationController
  load_and_authorize_resource :unit
  load_and_authorize_resource :sequence, through: :unit, parent: false

  # GET /sequences
  # GET /sequences.json
  def index
    @sequences_grid = initialize_grid(@sequences)
  end
end
