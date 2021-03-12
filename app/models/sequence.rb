class Sequence < ActiveRecord::Base
  belongs_to :unit

  def self.generate_asset_no(obj,date)
    asset_no = nil
  	if obj.asset_no.blank?
      # asset_no = Sequence.generate_barcode(Unit.find_by(id:(obj.use_unit_id.blank? ? obj.manage_unit_id : obj.use_unit_id)), obj.class, Sequence.generate_sequence(Unit.find_by(id:(obj.use_unit_id.blank? ? obj.manage_unit_id : obj.use_unit_id)), obj.class), date)
      asset_no = Sequence.generate_barcode(Unit.find_by(id: obj.manage_unit_id), obj.class, Sequence.generate_sequence(Unit.find_by(id: obj.manage_unit_id), obj.class), date)
    end
  end

  def self.generate_sequence(unit, _class)
    get_count(unit, _class).to_s.rjust(5, '0')
  end

  def self.generate_barcode(unit, _class, count, date)
    self.generate_initial(unit, _class).upcase + date.strftime("%Y%m").to_s + count
  end

  def self.get_count(unit, _class)
      sequence = find_by(unit_id: unit, entity: _class.to_s)
      sequence ||= Sequence.create(unit: unit, entity: _class.to_s, count: 1)
      success = false
      while !success
        begin
          success = sequence.update(count: sequence.count + 1)
        rescue => e
          sequence.reload
        end
      end
      sequence.count - 1
  end

  def self.generate_initial(unit, _class)
    initial = ""
    if _class.eql?RentInfo
      initial = "Q"
    end

    initial += unit.short_name.blank? ? "000": unit.short_name.rjust(3, '0')
  end

  
end








