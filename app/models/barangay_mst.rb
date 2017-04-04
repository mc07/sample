class BarangayMst < ActiveRecord::Base
	#include ModelRelationConcern::JoinCity
	#insert belongs_to here
	belongs_to :city_mst

	#insert has_many here
	
	#insert validations here
	validates :brgy_code, uniqueness: {scope: :city_mst_id, message:'already exists for the current City.'}
	validates :city_mst_id, :city_district, :brgy_code, :description, presence: true
	validates :city_district, :brgy_code, allow_blank: true, numericality: true
	validates :city_district, allow_blank: true, length: { minimum: 1, maximum: 2, message: "must be 2 digits." }
	validates :brgy_code, allow_blank: true, length: { is: 4, message: "must be 4 digits." }
	
	#insert before_delete validation
	ASSOC = self.reflect_on_all_associations(:has_many).collect{|att| att.name}
	include ModelRelationConcern::BeforeDestroyGeneric
	before_destroy {destroy_has_many_association ASSOC}
	
	private

	def self.join_tables
		self.joins(:city_mst)
	end

	def self.select_fields
		self.select("barangay_msts.*, city_msts.description as 'city_description'")
	end
	
	def self.default_order
		self.order("city_msts.description ASC, city_district ASC, brgy_code ASC")
	end
end
