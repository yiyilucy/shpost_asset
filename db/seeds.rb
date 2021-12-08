# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# unit1 = Unit.create(name: '中国邮政集团公司上海市分公司', unit_desc: '中国邮政集团公司上海市分公司', no: '0001', unit_level: 1)

# superadmin = User.create(email: 'superadmin@examples.com', username: 'superadmin', password: '11111111aa', name: 'superadmin', role: 'superadmin', unit_id: 0)

# role_1 = Role.create(user: superadmin, unit: unit1, role: 'superadmin')

I18n.t("same_unit_no").each do |k,v|
	Unit.where("name like ? and unit_level=?", "%#{k}%", 2).update_all same_unit_no: v
end