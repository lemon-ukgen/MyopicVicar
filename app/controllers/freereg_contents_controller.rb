# Copyright 2012 Trustees of FreeBMD
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
#
class FreeregContentsController < ApplicationController
  require 'chapman_code'
  require 'freereg_options_constants'
  skip_before_action :require_login
  skip_before_action :verify_authenticity_token

  def church
    @church = Church.id(params[:id]).first
    redirect_back(fallback_location: { action: 'new' }, notice: 'Non existent church has been selected.') && return if @church.blank?

    variables_for_church_show
    redirect_back(fallback_location: { action: 'new' }, notice: 'Non existent place for this church.') && return unless @proceed
  end

  def create
    case
    when params.present? && params[:freereg_content].present? && params[:freereg_content][:chapman_codes].present?#params[:commit] == "Select"
      @freereg_content = FreeregContent.new(freereg_content_params)
      @chapman_code = params[:freereg_content][:chapman_codes][1]
      session[:chapman_code] = @chapman_code
      if @freereg_content.save
        @county = ChapmanCode.name_from_code(@chapman_code)
        session[:county] = @county
        redirect_to freereg_contents_path
        return
      else
        @freereg_content.chapman_codes = []
        @options = ChapmanCode.add_parenthetical_codes(ChapmanCode.remove_codes(ChapmanCode::CODES))
        render :new
      end
    when params[:action] == 'create'
      proceed = FreeregContent.check_how_to_proceed(params[:freereg_content])
      case proceed
      when 'dual'
        flash[:notice] = 'Choose a place or a letter \u2014 you cannot choose both.'
        redirect_to(freereg_contents_path) && return
      when 'no option'
        flash[:notice] = 'Choose a place or a letter \u2014 you must choose something.'
        redirect_to(freereg_contents_path) && return
      when 'place'
        redirect_to(freereg_content_path(params[:freereg_content][:place])) && return
      when 'character'
        session[:character] = params[:freereg_content][:character]
        redirect_to(action: :select_places) && return
      end
    end
  end

  def index
    session[:character] = nil
    redirect_back(fallback_location: { action: 'new' }, notice: 'Non existent County has been selected.') && return if session[:chapman_code].blank? || !ChapmanCode::values.include?(session[:chapman_code])

    @show_alphabet = FreeregContent.determine_if_selection_needed(session[:chapman_code],session[:character])
    @page = FreeregContent.get_header_information(session[:chapman_code])
    @coordinator = County.coordinator_name(session[:chapman_code])
    @records = FreeregContent.number_of_records_in_county(session[:chapman_code])
    if @show_alphabet.zero?
      @places = FreeregContent.get_records_for_display(session[:chapman_code])
    else
      @freereg_content = FreeregContent.new
      @options = FreeregOptionsConstants::ALPHABETS[@show_alphabet]
      @places = FreeregContent.get_places_for_display(session[:chapman_code])
    end
    session[:show_alphabet] = @show_alphabet
    @county = session[:county]
    @chapman_code = session[:chapman_code]
    @character = session[:character]
  end

  def new
    session[:character] = nil
    session[:county] = nil
    session[:chapman_code] = nil
    @freereg_content = FreeregContent.new
    @options = ChapmanCode.add_parenthetical_codes(ChapmanCode.remove_codes(ChapmanCode::CODES))
  end

  def send_request_email
    applier_name = params[:email_info][:name]
    applier_email = params[:email_info][:email]
    group_name = params[:email_info][:group]

    image_server_group = ImageServerGroup.where(:group_name=>group_name).first
    redirect_to request.referer + '#image_information' and return if image_server_group.blank?

    group_status = image_server_group.summary[:status]

    if group_status.include? 'a'
      syndicate = Syndicate.where(:syndicate_code=>image_server_group.syndicate_code).first

      if !syndicate.blank?
        syndicate_coordinator = syndicate.syndicate_coordinator

        if !(syndicate_coordinator.blank? and syndicate_coordinator.empty?)
          sc = UseridDetail.where(:userid=>syndicate_coordinator).first

          if !sc.blank?
            UserMailer.request_to_volunteer(sc,group_name,applier_name,applier_email).deliver_now

            flash[:notice] = 'email is sent to syndicate coordinator'
            redirect_to request.referer + '#image_information' and return
          end
        end
      end
    end

    vc = UseridDetail.where(:person_role=>'volunteer_coordinator').first

    if vc.blank?
      vc = UseridDetail.where(:secondary_role=>'volunteer_coordinator').first
      flash[:notice] = 'No coordinator is found to process this image group'
      redirect_to request.referer + '#image_information' and return if vc.blank?
    end

    UserMailer.request_to_volunteer(vc,group_name,applier_name,applier_email).deliver_now

    flash[:notice] = 'email is sent to volunteer coordinator'
    redirect_to request.referer + '#image_information'
  end

  def place
    @place = Place.id(params[:id]).first
    redirect_back(fallback_location: { action: 'new' }, notice: 'Non existent place has been selected.') && return if @place.blank?

    variables_for_place_show
  end

  def register
    # this is the search details entry for a register
    @register = Register.id(params[:id]).first
    redirect_back(fallback_location: { action: 'new' }, notice: 'Non existent register has been selected.') && return if @register.blank?

    variables_for_register_show
    redirect_back(fallback_location: { action: 'new' }, notice: 'Non existent register has been selected.') && return unless @proceed
  end

  def select_places
    @character = session[:character]
    @show_alphabet = session[:show_alphabet]
    @county = session[:county]
    @chapman_code = session[:chapman_code]
    redirect_back(fallback_location: { action: 'new' }, notice: 'Non existent place has been selected.') && return if @chapman_code.blank? || @county.blank? || @character.blank?

    @coordinator = County.coordinator_name(@chapman_code)
    @page = FreeregContent.get_header_information(@chapman_code)
    allplaces = Place.chapman_code(@chapman_code).not_disabled.data_present.all.order_by(place_name: 1)
    @places = []
    allplaces.each do |place|
      @places << place if place.place_name =~ /^[#{@character}]/i
    end
    @records = FreeregContent.number_of_records_in_county(@chapman_code)
    render '_show_body'
  end

  def show
    redirect_back(fallback_location: { action: 'new' }, notice: 'Non existent place has been selected.') && return if params[:id].blank?

    @county = session[:county]
    @chapman_code = session[:chapman_code]
    @character = session[:character]
    redirect_back(fallback_location: { action: 'new' }, notice: 'Non existent County has been selected.') && return if session[:chapman_code].blank? || !ChapmanCode::values.include?(session[:chapman_code])

    @place = Place.chapman_code(@chapman_code).place(params[:id]).not_disabled.data_present.first
    redirect_back(fallback_location: { action: 'new' }, notice: 'Non existent place has been selected.') && return if @place.blank?

    @page = FreeregContent.get_header_information(session[:chapman_code])
    @coordinator = County.coordinator_name(session[:chapman_code])
    @records = FreeregContent.number_of_records_in_county(session[:chapman_code])
  end

  def show_church
    @church = Church.id(params[:id]).first
    redirect_back(fallback_location: { action: 'new' }, notice: 'Non existent church has been selected.') && return if @church.blank?

    variables_for_church_show
    redirect_back(fallback_location: { action: 'new' }, notice: 'Non existent place for this church.') && return unless @proceed

    @character = session[:character]
    @county = session[:county]
    @chapman_code = session[:chapman_code]
  end

  def show_place
    @county = session[:county]
    @chapman_code = session[:chapman_code]
    @place = Place.chapman_code(@chapman_code).place(params[:id]).not_disabled.data_present.first
    redirect_back(fallback_location: { action: 'new' }, notice: 'Non existent place has been selected.') && return if @place.blank?

    variables_for_place_show
    @character = session[:character]
    @county = session[:county]
    @chapman_code = session[:chapman_code]
  end

  def show_register
    # this is the Transcription entry for a register
    @register = Register.id(params[:id]).first
    redirect_back(fallback_location: { action: 'new' }, notice: 'No register was selected while reviewing the content; you will need to start again') && return if @register.blank?

    @images = Register.image_transcriptions_calculation(params[:id])
    @church = @register.church
    redirect_back(fallback_location: { action: 'new' }, notice: 'The register has no church; you will need to start again') && return if @church.blank?

    variables_for_register_show
    redirect_back(fallback_location: { action: 'new' }, notice: 'The register has no place; you will need to start again') && return unless @proceed

    @character = session[:character]
    @county = session[:county]
    @chapman_code = session[:chapman_code]
  end

  def variables_for_church_show
    @proceed = true
    @character = nil
    @place = @church.place
    if @place.blank?
      @proceed = false
    else
      @chapman_code = @place.chapman_code
      @county = @place.county
      if @county.blank? || @chapman_code.blank?
        @proceed = false
      else
        @registers_count = @church.registers.count
        @coordinator = County.coordinator_name(@chapman_code)
        @place_name = @place.place_name
        @names = @church.get_alternate_church_names
        @church_name = @church.church_name
        @decade = @church.daterange
        @transcribers = @church.transcribers
        @contributors = @church.contributors
        @registers = Register.where(church_id: params[:id]).order_by(:record_types.asc, :register_type.asc, :start_year.asc).all
      end
    end
  end

  def variables_for_place_show
    @character = nil
    @county = @place.place_name
    @chapman_code = @place.chapman_code
    @coordinator = County.coordinator_name(@chapman_code)
    @place_name = @place.place_name
    @churches_count = @place.churches.count
    @names = @place.get_alternate_place_names
    @decade = @place.daterange
    @transcribers = @place.transcribers
    @contributors = @place.contributors
  end

  def variables_for_register_show
    @proceed = true
    @church = @register.church
    if @church.blank?
      @proceed = false
    else
      @place = @church.place
      if @place.blank?
        @proceed = false
      else
        @county = @place.county
        @chapman_code = @place.chapman_code
        @place_name = @place.place_name
        @register_name = @register.register_name
        @register_name = @register.alternate_register_name if @register_name.blank?
        @church_name = @church.church_name
        @register_type = RegisterType.display_name(@register.register_type)
        @decade = @register.daterange
        @transcribers = @register.transcribers
        @contributors = @register.credit
      end
    end
  end

  private

  def freereg_content_params
    params.require(:freereg_content).permit!
  end
end
