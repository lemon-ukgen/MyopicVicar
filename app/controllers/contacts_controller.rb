class ContactsController < InheritedResources::Base
  require 'freereg_options_constants'
  skip_before_filter :require_login, only: [:new, :report_error, :create]
  def index
    get_user_info_from_userid
    if @user.person_role == 'county_coordinator' || @user.person_role == 'country_coordinator'
      @county = @user.county_groups
      @contacts = Contact.in(:county => @county).all.order_by(contact_time: -1)
    else
      @contacts = Contact.all.order_by(contact_time: -1)
    end  
  end

  def show
    @contact = Contact.id(params[:id]).first
    if @contact.nil?
      go_back("contact",params[:id])
    else
      set_session_parameters_for_record(@contact) if @contact.entry_id.present?
    end
  end

  def list_by_name
    get_user_info_from_userid
    @contacts = Contact.all.order_by(name: 1)
    render :index
  end

  def list_by_identifier
    get_user_info_from_userid
    @contacts = Contact.all.order_by(identifier: -1)
    render :index
  end

  def list_by_type
    get_user_info_from_userid
    @contacts = Contact.all.order_by(contact_type: 1)
    render :index
  end


  def list_by_date
    get_user_info_from_userid
    @contacts = Contact.all.order_by(contact_time: 1)
    render :index
  end

  def select_by_identifier
    get_user_info_from_userid
    @options = Hash.new
    @contacts = Contact.all.order_by(identifier: -1).each do |contact|
      @options[contact.identifier] = contact.id
    end
    @contact = Contact.new
    @location = 'location.href= "/contacts/" + this.value'
    @prompt = 'Select Identifier'
    render '_form_for_selection'
  end

  def new
    @contact = Contact.new
    @options = FreeregOptionsConstants::ISSUES
    @contact.contact_time = Time.now
    @contact.contact_type = FreeregOptionsConstants::ISSUES[0]
  end

  def create
    @contact = Contact.new(params[:contact])
    if @contact.contact_name.blank? #spam trap
      session.delete(:flash)
      @contact.session_data = session
      @contact.previous_page_url= request.env['HTTP_REFERER']
      if @contact.selected_county == 'nil'
        @contact.selected_county = nil
      end
      if @contact.save
        flash[:notice] = "Thank you for contacting us!"
        @contact.communicate
        if @contact.query
          redirect_to search_query_path(@contact.query, :anchor => "#{@contact.record_id}")
          return
        else
          redirect_to @contact.previous_page_url
          return
        end
      else
        @options = FreeregOptionsConstants::ISSUES
        @contact.contact_type = FreeregOptionsConstants::ISSUES[0]
        render :new
        return
      end
    else
      redirect_to @contact.previous_page_url
      return
    end
  end

  def edit
    load(params[:id]) 
    if @contact.github_issue_url.present?
      flash[:notice] = "Issue cannot be edited as it is already committed to GitHub. Please edit there"
      redirect_to :action => 'show'
      return
    end  
  end
  
  def update
    load(params[:id])
    @contact.update_attributes(params[:contact])
    redirect_to :action => 'show'
  end

  def report_error
    @contact = Contact.new
    @contact.contact_time = Time.now
    @contact.contact_type = 'Data Problem'
    @contact.query = params[:query]
    @contact.record_id = params[:id]
    if MyopicVicar::Application.config.template_set == 'freereg'
      @contact.entry_id = SearchRecord.find(params[:id]).freereg1_csv_entry._id
      @freereg1_csv_entry = Freereg1CsvEntry.find( @contact.entry_id)
      @contact.county = @freereg1_csv_entry.freereg1_csv_file.register.church.place.chapman_code
      @contact.line_id  = @freereg1_csv_entry.line_id
    elsif MyopicVicar::Application.config.template_set == 'freecen'
      rec = SearchRecord.where("id" => @contact.record_id).first
      unless rec.nil?
        p rec
        @contact.entry_id = 'freecen'
        fc_ind = rec.freecen_individual_id if rec.freecen_individual_id.present?
        fc_ind = rec.freecen_individual._id unless rec.freecen_individual.nil?
        @contact.fc_individual_id = fc_ind.to_s unless fc_ind.nil?
        @contact.county = rec.chapman_code
      end
    end
  end

  def delete
    Contact.find(params[:id]).destroy
    flash.notice = "Contact destroyed"
    redirect_to :action => 'index'
  end

  def convert_to_issue
    @contact = load(params[:id])
    if @contact.github_issue_url.blank?
      @contact.github_issue
      flash.notice = "Issue created on Github."
      redirect_to contact_path(@contact.id)
      return
    else
      flash.notice = "Issue has already been created on Github."
      redirect_to :show
      return
    end 

  end

  def set_session_parameters_for_record(contact)
    if MyopicVicar::Application.config.template_set == 'freereg'
      file_id = Freereg1CsvEntry.find(contact.entry_id).freereg1_csv_file
      file = Freereg1CsvFile.find(file_id)
      church = file.register.church
      place = church.place
      session[:freereg1_csv_file_id] = file._id
      session[:freereg1_csv_file_name] = file.file_name
      session[:place_name] = place.place_name
      session[:church_name] = church.church_name
      session[:county] = place.county
    end
  end

  def message
    
    
  end

  def load(contact)
    @contact = Contact.id(contact).first
    if @contact.blank?
      go_back("contact",contact)
    end  
    @contact 
  end
end
