class BarangayMstsController < ApplicationController
	include ApplicationHelper

	path = "barangay_msts_path"
	before_action :set_barangay_mst, only: [:show, :edit, :update, :destroy]
	before_filter {check_if_admin}
	before_filter {screened_menu_authorize path}
	before_action {access_rights path, only: [:index], levels_only: true}
	before_action {access_rights path, only: [:show, :new, :edit, :update, :destroy], levels_only: false}
	
	def index
		#added = query(session[:city_mst_id])
		@can_print = self.respond_to?('print')
		@optional_city_on_print = true
		
		@field_types = ["search_field"]
		@field_names = ["barangay_mst_city_mst_id"]
		@field_ids = ["barangay_mst_city_mst_id"]
		@field_labels = ["City"]

		@custom = [0]
		@tbl = ["CityMst"]
		@condition = [nil]
		@ord = ["id asc&path=city_msts_path"]
		@lbl = ["City"]
		@tf_ids = ["tf_city"]
		@tf_names = ["tf_city"]
		@tbl_sms = ["city_msts"]
		
		if params[:search].blank?
			@barangay_msts =BarangayMst.join_tables.default_order.select_fields.paginate(:page => params[:page], :per_page => 10)
		else
			reconstruct_progress(params[:search]) 
			if params[:filter] == "city_description"
				@barangay_msts = BarangayMst.join_tables.default_order.select_fields.where("city_msts.description like ?", "#{@new_str}%").paginate(:page => params[:page], :per_page => 10)
			elsif params[:filter] == "city_district"
				@barangay_msts = BarangayMst.join_tables.default_order.select_fields.where("#{params[:filter]} = ?", "#{@new_str.to_i}").paginate(:page => params[:page], :per_page => 10)
			else
				@barangay_msts = BarangayMst.join_tables.default_order.select_fields.where("barangay_msts.#{params[:filter]} like ?", "#{@new_str}%").paginate(:page => params[:page], :per_page => 10)
			end
		end
	end

	def show
	end

	def new
		@barangay_mst = BarangayMst.new
		if (!params[:t].blank?) && (!params[:pop_city_id].blank?)
			@city_name = ""
			city = CityMst.where(id: [params[:pop_city_id]]).first
			if !city.blank?
				@city_name = city.description
			end
		end
	end

	def edit
		@city_name = @barangay_mst.city_description
		@curr_district_code = @barangay_mst.city_district
	end

	def create
		#Add if multiple record needs to be save
		#ActiveRecord::Base.transaction 
		@city_name = params[:tf_city]
		@barangay_mst = BarangayMst.new(barangay_mst_params)
		respond_to do |format|
			if @barangay_mst.save
				if params[:t].blank?
					format.html { redirect_to @barangay_mst, notice: 'Barangay was successfully created.' }
					format.json { render :show, status: :created, location: @barangay_mst }
				else
					format.html { redirect_to :controller => "popup", :action => "save", t: params[:t], id: @barangay_mst }
				end
			else
				format.html { render :new }
				format.json { render json: @barangay_mst.errors, status: :unprocessable_entity }
			end
		end
	end

	def update
		#Add if multiple record needs to be save
		#ActiveRecord::Base.transaction
		respond_to do |format|
				if @barangay_mst.update(barangay_mst_params)
						format.html { redirect_to @barangay_mst, notice: 'Barangay was successfully updated.' }
						format.json { render :show, status: :ok, location: @barangay_mst }
				else
						format.html { render :edit }
						format.json { render json: @barangay_mst.errors, status: :unprocessable_entity }
				end
		end
	end

	def destroy
		#Add if multiple record needs to be save
		#ActiveRecord::Base.transaction
		respond_to do |format|
				if @barangay_mst.destroy
						format.html { redirect_to barangay_msts_url, notice: 'Barangay was successfully deleted.' }
						format.json { head :no_content }
				else
						format.html { redirect_to barangay_msts_url, notice: 'Cannot delete. Already in used.' }
						format.json { head :no_content }
				end
		end
	end
	
	def print
		@system_name = get_param_content("system_name")
		if !params[:barangay_mst_city_mst_id].blank?
			jasper_connect(:report => "rpt_inquiry", :file => "barangay_msts", :format => "pdf", :new_name => "barangay", :parameters => [["user_name", "#{current_user_mst.first_name}"], ["report_name", "Barangay Masterlist"], ["system_name", "#{@system_name}"], ["citymstid", params[:barangay_mst_city_mst_id]]])
		else
			jasper_connect(:report => "rpt_inquiry", :file => "barangay_msts", :format => "pdf", :new_name => "barangay", :parameters => [["user_name", "#{current_user_mst.first_name}"], ["report_name", "Barangay Masterlist"], ["system_name", "#{@system_name}"]])
		end
	end

	private
		def set_barangay_mst
			@barangay_mst = BarangayMst.join_tables.select_fields.where(:id => [params[:id]]).first
		end

		def barangay_mst_params
			params[:barangay_mst].permit!
		end
end
