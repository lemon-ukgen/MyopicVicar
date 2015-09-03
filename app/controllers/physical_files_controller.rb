class PhysicalFilesController < InheritedResources::Base

  def index
    if params[:page]
      session[:physical_index_page] = params[:page]
    end
    @sorted_by = "(All files by userid then batch name)"
    @sorted_by = session[:sorted_by] unless session[:sorted_by].nil?
    get_user_info_from_userid
    if session[:who].nil?
      @person = "All"
    else
      @person = session[:who]
    end
    case
    when   @sorted_by == "(All files by userid then batch name)"
      @batches = PhysicalFile.all.order_by(userid: 1,batch_name: 1).page(params[:page])
    when @sorted_by == '(File not processed)' 
      @batches = PhysicalFile.not_processed.all.order_by(userid: 1,base_uploaded_date: 1).page(params[:page]) 
    when @sorted_by ==  "Not Processed"  
      @batches = PhysicalFile.userid(session[:who]).not_processed.all.order_by(userid: 1,base_uploaded_date: 1).page(params[:page])
    when   @sorted_by == '(Processed but no file)'
      @batches = PhysicalFile.processed.not_uploaded_into_base.all.page(params[:page])
    when   @sorted_by == "Processed but no File" 
      @batches = PhysicalFile.userid(session[:who]).processed.not_uploaded_into_base.all.order_by(userid: 1,file_processed_date: 1).page(params[:page])
    when  @sorted_by == 'all files'
      @batches = PhysicalFile.all.order_by(userid: 1,base_uploaded_date: 1).page(params[:page])
    when   @sorted_by == 'All'
      @batches = PhysicalFile.userid(session[:who]).all.order_by(userid: 1,base_uploaded_date: 1).page(params[:page])
    when  @sorted_by == 'processed but no file'
      @batches = PhysicalFile.userid(@user).processed.not_uploaded_into_base.all.order_by(userid: 1,file_processed_date: 1).page(params[:page])  
    when  @sorted_by == 'files_not processed'
      @batches = PhysicalFile.userid(@user).not_processed.all.order_by(userid: 1,base_uploaded_date: 1).page(params[:page])
    else
      @batches = PhysicalFile.all.order_by(userid: 1,batch_name: 1).page(params[:page])
    end
  end 
  def show
    #show an individual batch
    get_user_info_from_userid
    load(params[:id])  
  end
  def create
    if params[:commit] == "Select"
      #This is not the creation of a physical file but simply the selection of who and how to display the files
      session[:sorted_by] = params[:physical_file][:type] 
      session[:who] = params[:physical_file][:userid] 
      redirect_to  :action => 'index'
    return
    end
  end
  def select_action
    clean_session
    clean_session_for_county
    clean_session_for_syndicate
    get_user_info_from_userid
    @batches = PhysicalFile.new
    @options= UseridRole::PHYSICAL_FILES_OPTIONS
    @prompt = 'Select Action?'
  end

  def load(batch)
    @batch = PhysicalFile.find(batch)
  end
  
  def file_not_processed
    session[:sorted_by] = '(File not processed)'
    session[:who] = nil
    redirect_to  :action => 'index'   
  end
  
  def processed_but_no_file 
    session[:sorted_by] = '(Processed but no file)'
    session[:who] = nil
    redirect_to  :action => 'index'   
  end
  def all_files
    session[:sorted_by] = "(All files by userid then batch name)"
    session[:who] = nil
    redirect_to  :action => 'index'   
  end
  def files_for_specific_userid
    get_user_info_from_userid
    @batch = PhysicalFile.new
    @users = UseridDetail.get_userids_for_selection('all')  
  end

  def submit_for_processing
    load(params[:id])
    success = @batch.add_file(params[:loc])
    flash[:notice] = "The file #{@batch.file_name} for #{@batch.userid} has been added to the overnight queue for processing" if success
    redirect_to physical_files_path(:anchor => "#{@batch.id}", :page => "#{ session[:physical_index_page] }")   
  end
  def reprocess
      file = Freereg1CsvFile.find(params[:id])
      #we write a new copy of the file from current on-line contents
      file.backup_file
      @batch = PhysicalFile.where(:file_name => file.file_name, :userid => file.userid).first
      #add to processing queue and place in change
      success = @batch.add_file("reprocessing")
      flash[:notice] = "The file #{@batch.file_name} for #{@batch.userid} has been added to the overnight queue for processing" if success
      @batch.save
      redirect_to :back#freereg1_csv_files_path(:anchor => "#{file.id}", :page => "#{session[:files_index_page]}")
  end
  def destroy
    load(params[:id])
    @batch.file_delete
    @batch.destroy
    flash[:notice] = 'The destruction of the physical files and all its entries and search records was successful'
    redirect_to :back 
  end

end