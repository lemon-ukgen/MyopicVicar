crumb :root do
  link 'Your Actions:', main_app.new_manage_resource_path
end



# userid details .................................................

crumb :my_own_userid_detail do |userid_detail|
  link "Profile:#{userid_detail.userid}", my_own_userid_detail_path
  parent :root
end

crumb :edit_userid_detail do |syndicate, userid_detail, page_name|
  link "Edit Profile:#{userid_detail.userid}", userid_detail_path
  if session[:my_own]
    parent :my_own_userid_detail, userid_detail
  else
    parent :userid_detail, syndicate, userid_detail, page_name
  end
end

crumb :disable_userid_detail do |userid_detail|
  link "Disable Profile:#{userid_detail.userid}", userid_detail_path
  parent :userid_detail, session[:syndicate], userid_detail
end

crumb :create_userid_detail do |userid_detail|
  link 'Create New Profile', new_userid_detail_path

  if session[:role] == 'syndicate_coordinator' || session[:role] == 'county_coordinator' ||
      session[:role] == 'country_coordinator' || session[:role] == 'volunteer_coordinator' ||
      session[:role] == 'data_manager'
    parent :userid_details_listing, session[:syndicate], userid_detail
  end
  if session[:role] == 'system_administrator' || session[:role] == 'technical'
    parent :userid_details_listing, 'all', userid_detail
  end
end

crumb :transcriber_statistics do
  link "Transcriber Statistics"
  parent :regmanager_userid_options
end

crumb :secondary_role_selection do
  link 'Secondary Role Selection'
  parent :regmanager_userid_options
end

crumb :person_role_selection do
  link 'Role Selection'
  parent :regmanager_userid_options
end

#................................................File....................................................

crumb :my_own_files do
  link 'Your Batches', my_own_freereg1_csv_file_path
end

crumb :files do |file|
  if session[:my_own].present?
    link 'Your Batches', my_own_freereg1_csv_file_path
    parent :root
  else
    if file.nil?
      link 'List of Batches', freereg1_csv_files_path
    else
      link 'List of Batches', freereg1_csv_files_path(:anchor => "#{file.id}", :page => "#{session[:current_page]}")
    end
    case
    when session[:county].present? && (session[:role] == 'county_coordinator' ||
                                       session[:role] == 'system_administrator' || session[:role] == 'technical' ||
                                       session[:role] == 'data_manager')
      if session[:place_name].present?
        place = Place.where(:chapman_code => session[:chapman_code], :place_name => session[:place_name]).first
        unless place.nil?
          parent :show_place, session[:county], place
        else
          parent :county_options, session[:county]
        end
      else
        parent :county_options, session[:county]
      end
    when session[:role] == 'volunteer_coordinator' || session[:role] == 'syndicate_coordinator'
      parent :userid_details_listing, session[:syndicate]
    when session[:syndicate].present? && (session[:role] == 'county_coordinator' || session[:role] == 'data_manager' ||session[:role] == 'system_administrator' || session[:role] == 'technical')
      unless  session[:userid_id].nil?
        parent :userid_detail, session[:syndicate], UseridDetail.find(session[:userid_id])
      else
        parent :syndicate_options, session[:syndicate]
      end
    when session[:role] == 'system_administrator' || session[:role] == 'technical'
      parent :regmanager_userid_options
    end
  end
end

crumb :show_file do |file|
  link 'Batch Information', freereg1_csv_file_path(file.id)
  if session[:my_own]
    parent :files, file
  else
    if session[:register_id].present? && session[:county].present? && session[:place_id].present? && session[:church_id].present? && session[:register_id].present?
      place = Place.id(session[:place_id]).first
      church = Church.id(session[:church_id]).first
      register = Register.id(session[:register_id]).first
      if place.present? && church.present? && register.present?
        parent :show_register, session[:county], place, church, register
      end
    else
      parent :files, file
    end
  end
end

crumb :unique_names do |file|
  link 'Unique Names'
  parent :show_file, file
end

crumb :edit_file do |file|
  link 'Editing Batch Information', edit_freereg1_csv_file_path(file)

  parent :show_file, file
end
crumb :relocate_file do |file|
  link 'Relocating Batch', freereg1_csv_file_path(file)
  parent :show_file, file
end
crumb :waiting do |file|
  link 'Files waiting to be processed'
  if session[:my_own]
    parent :my_own_files
  else
    parent :files, file
  end
end
crumb :change_userid do |file|
  link 'Changing owner'
  parent :show_file, file
end
crumb :select_file do |user|
  link 'Selecting file'
  if session[:my_own]
    parent :my_own_files
  else
    parent :files, file
  end
end



#record or entry
crumb :show_records do |entry, file|
  if entry.nil?
    link 'List of Records', freereg1_csv_entries_path
  else
    link 'List of Records', freereg1_csv_entries_path(:anchor => "#{entry.id}")
  end
  parent :show_file, file
end
crumb :new_record do |entry, file|
  link 'Create New Record', new_freereg1_csv_entry_path
  parent :show_records, entry,file
end
crumb :error_records do |file|
  link 'List of Errors', error_freereg1_csv_file_path(file)
  parent :show_file, file
end
crumb :show_record do |entry, file|
  link 'Record Contents', freereg1_csv_entry_path(entry)
  parent :show_records, entry,file
end
crumb :edit_record do |entry, file|
  link 'Edit Record', edit_freereg1_csv_entry_path(entry)
  parent :show_record, entry,file
end
crumb :correct_error_record do |entry, file|
  link 'Correct Error Record', error_freereg1_csv_entry_path(entry._id)
  parent :error_records, file
end

# manage county
crumb :county_selection do
  link 'Select County'
  parent :root
end

crumb :county_options do |county|
  link "County Options(#{county})", select_action_manage_counties_path(:county => "#{county}")
  parent :root
end

crumb :place_range_options do |county, active|
  if session[:active_place]
    link 'Range Selection', selection_active_manage_counties_path(:option =>'Work with Active Places')
  else
    link 'Range Selection', selection_all_manage_counties_path(:option =>'Work with All Places')
  end
  parent :county_options, county
end

crumb :manage_county_selection do |county|
  link 'Selection'
  parent :county_options, county
end

crumb :places do |county, place|
  case
  when session[:character].present?
    link 'Places', place_range_manage_counties_path
  when place.blank?
    link 'Places', places_path
  when place.present?
    link 'Places', places_path(:anchor => 'session[place.id]')
  end
  if session[:character].present?
    parent :place_range_options, county,session[:active]
  else
    parent :county_options, county
  end
end

crumb :places_range do |county, place|
  link 'Places', places_path
  parent :place_range_options, county,session[:active]
end

crumb :show_place do |county, place|
  link 'Place Information', place_path(place)
  case
  when session[:select_place] || place.blank?
    parent :county_options, session[:county] if session[:county].present?
    parent :syndicate_options, session[:syndicate] if session[:syndicate].present?
  when place.present?
    parent :places, county, place
  end

end
crumb :edit_place do |county, place|
  link 'Edit Place Information', edit_place_path(place)
  parent :show_place, county, place
end
crumb :create_place do |county, place|
  link 'Create New Place', new_place_path
  parent :places, county, place
end
crumb :rename_place do |county, place|
  link 'Rename Place', rename_place_path
  parent :places, county, place
end
crumb :relocate_place do |county, place|
  link 'Relocate Place', relocate_place_path
  parent :places, county, place
end
crumb :show_church do |county, place, church|
  if church.present?
    link 'Church Information', church_path(church)
    parent :show_place, county, place
  else
    parent :county_options, session[:county] if session[:county].present?
    parent :syndicate_options, session[:syndicate] if session[:syndicate].present?
  end
end
crumb :edit_church do |county, place, church|
  link 'Edit Church Information', edit_church_path(church)
  parent :show_church, county, place, church
end
crumb :create_church do |county, place|
  link 'Create New Church', new_church_path
  parent :show_place, county, place
end
crumb :rename_church do |county, place, church|
  link 'Rename Church', rename_church_path
  parent :show_church, county, place, church
end
crumb :relocate_church do |county,place,church|
  link 'Relocate Church', relocate_church_path
  parent :show_church, county, place, church
end
crumb :show_register do |county, place, church, register|
  if register.present?
    link 'Register Information', register_path(register)
    parent :show_church, county, place, church
  else
    parent :county_options, session[:county] if session[:county].present?
    parent :syndicate_options, session[:syndicate] if session[:syndicate].present?
  end
end
crumb :edit_register do |county, place, church, register|
  link 'Edit Register Information', edit_register_path(register)
  parent :show_register, county, place, church, register
end
crumb :create_register do |county, place, church|
  link 'Create New Register', new_register_path
  parent :show_church, county, place, church
end
crumb :rename_register do |county, place, church, register|
  link 'Rename Register', rename_register_path
  parent :show_register, county, place, church, register
end

# manage syndicate
crumb :syndicate_selection do
  link 'Select Syndicate'
  parent :root
end

crumb :syndicate_options do |syndicate|
  link "Syndicate Options(#{syndicate})", select_action_manage_syndicates_path("?syndicate=#{syndicate}")
  parent :root
end

crumb :manage_syndicate_selection do |syndicate|
  link 'Selection'
  parent :syndicate_options, syndicate
end

crumb :userid_details_listing do |syndicate, user|
  case
  when syndicate == 'all'
    link 'All Members', userid_details_path
  when user.nil?
    link 'Syndicate Listing', userid_details_path
  when !user.nil?
    unless session[:manager].nil?
      link 'Syndicate Listing', userid_details_path(:anchor => "#{user.id}", :page => "#{session[:manager]}")
    else
      link 'Syndicate Listing', userid_details_path(:anchor => "#{user.id}")
    end
  end
  case
  when session[:syndicate].present? && session[:syndicate] == 'all'
    parent:regmanager_userid_options
  when !session[:syndicate].nil? && (session[:role] == 'county_coordinator' ||
                                     session[:role] == 'system_administrator' || session[:role] == 'technical' ||
                                     session[:role] == 'volunteer_coordinator' || session[:role] == 'syndicate_coordinator' )
    parent :syndicate_options, session[:syndicate]
  when session[:role] == 'system_administrator' || session[:role] == 'technical'
    parent :regmanager_userid_options
  else
    parent :syndicate_options, syndicate
  end
end

crumb :syndicate_waiting do |syndicate|
  link 'Files waiting to be processed'
  parent :syndicate_options,syndicate
end


#Profile
crumb :userid_detail do |syndicate, userid_detail, page_name, option|
  link "Profile:#{userid_detail.userid}", userid_detail_path(userid_detail.id)
  case
  when session[:my_own]
    parent :root
  when page_name == 'incomplete_registrations'
    parent :incomplete_registrations, syndicate
  when option
    parent :selection_user_id, option, syndicate
  when session[:manage_user_origin] == 'manage syndicate'
    parent :syndicate_options, syndicate
  when session[:edit_userid]
    syndicate = syndicate
    syndicate = 'all'  if session[:role] == 'system_administrator' || session[:role] == 'technical'
    parent :userid_details_listing, syndicate, userid_detail
  else
    parent :coordinator_userid_options
  end
end

crumb :selection_user_id do |selection, syndicate|
  link "#{selection}", selection_userid_details_path(option: selection, syndicate: syndicate)
  case
  when session[:manage_user_origin] == 'manage syndicate'
    parent :syndicate_options, syndicate
  when session[:edit_userid]
    if syndicate.nil? || syndicate == 'all'
      parent :regmanager_userid_options
    else
      parent :syndicate_options, syndicate
    end
  else
    parent :coordinator_userid_options
  end

end

#manage userids
crumb :regmanager_userid_options do
  link 'Userid Management Options', options_userid_details_path
  parent :root
end
crumb :coordinator_userid_options do
  link 'Profile Display Selection', display_userid_details_path
  parent :root
end
crumb :rename_userid do |user|
  link 'Rename Userid', rename_userid_details_path
  parent :userid_detail, user.syndicate,user
end
crumb :role_listing do
  link 'Role Listing'
  parent :regmanager_userid_options
end

#Incomplete Registrations
crumb :incomplete_registrations do |syndicate|
  link 'Incomplete Registration Listing', incomplete_registrations_userid_details_path
  if syndicate == 'all'
    parent :regmanager_userid_options
  else
    parent :syndicate_options,syndicate
  end
end

crumb :import do
  link 'Import Users', import_userid_details_path
  parent :regmanager_userid_options
end


#Physical Files

crumb :physical_files_options do
  link 'Physical Files Options', select_action_physical_files_path
  parent :root
end
crumb :physical_files do |syndicate, type|
  link 'Listing of Physical Files', physical_files_path
  if type == 'syndicate'
    parent :syndicate_options, syndicate
  else
    parent :physical_files_options
  end
end
crumb :show_physical_files do |physical_file|
  link 'Show a Physical File', physical_file_path(physical_file)
  parent :physical_files
end

#csvfiles
crumb :new_csvfile do |csvfile|
  link 'Upload New File', new_csvfile_path
  case
  when session[:my_own]
    parent :files, nil
  when session[:county]
    parent :county_options, session[:county]
  when session[:syndicate]
    parent :syndicate_options, session[:syndicate]
  end
end
crumb :edit_csvfile do |csvfile, file|
  link 'Replace File', edit_csvfile_path
  case
  when session[:my_own]
    parent :files, file
  when session[:county]
    parent :files, file
    #parent :county_options, session[:county]
  when session[:syndicate]
    parent :syndicate_options, session[:syndicate]
  end
end
# ................................................................. Feedback

crumb :feedback_form do
  parent :root
end
crumb :feedbacks do
  if session[:archived_contacts]
    link 'Archived Feedbacks', list_archived_feedbacks_path
  else
    link 'Active Feedbacks', feedbacks_path
  end
  parent :root
end
crumb :archived_feedbacks do
  link 'Archived Feedbacks', list_archived_feedbacks_path
  parent :root
end
crumb :show_feedback do |feedback|
  link 'Show Feedback', feedback_path(feedback)
  if session[:archived_contacts]
    parent :archived_feedbacks
  else
    parent :feedbacks
  end
end

crumb :feedback_messages do |message|
  link 'Feedback Reply Messages', feedback_reply_messages_path(message.id)
  parent :feedbacks
end

crumb :edit_feedback do |feedback|
  link 'Edit Feedback', edit_feedback_path(feedback)
  if session[:archived]
    parent :archived_feedbacks
  else
    parent :feedbacks
  end
end
crumb :feedback_form_for_selection do ||
    link 'Form for Selection'
  if session[:archived_contacts]
    parent :archived_feedbacks
  else
    parent :feedbacks
  end
end
crumb :create_feedback_reply do |feedback|
  link 'Create Feedback Reply'
  parent :show_feedback, feedback
end

crumb :feedback_messages do |message|
  link 'Feedback Replies', feedback_reply_messages_path(message.id, source: params[:source])
  parent :feedbacks
end

crumb :show_reply_feedback_message do |message|
  link 'Feedback Reply', show_reply_message_path(message.id, source: params[:source])
  if session[:message_base] == 'userid_messages'
    parent :userid_messages, source: params[:source]
  else
    parent :feedback_messages, Feedback.find(message.source_feedback_id), source: params[:source]
  end
end

# ..........................................................................manage contacts
crumb :contacts do
  if session[:archived_contacts]
    link 'Archived Contacts', list_archived_contacts_path
  else
    link 'Active Contacts', contacts_path
  end
  parent :root
end
crumb :archived_contacts do
  link 'Archived Contacts', list_archived_contacts_path
  parent :root
end
crumb :show_contact do |contact|
  link 'Show Contact', contact_path(contact)
  if session[:archived_contacts]
    parent :archived_contacts
  else
    parent :contacts
  end
end
crumb :edit_contact do |contact|
  link 'Edit Contact', edit_contact_path(contact)
  if session[:archived_contacts]
    parent :archived_contacts
  else
    parent :contacts
  end
end

crumb :contact_form_for_selection do
  link 'Form for Selection'
  if session[:archived_contacts]
    parent :archived_contacts
  else
    parent :contacts
  end
end
crumb :create_contact_reply do |message|
  link 'Create Reply for Contact', reply_contact_path(message.id)
  parent :contacts
end

crumb :contact_messages do |message|
  link 'Contact Replies', contact_reply_messages_path(message.id, source: params[:source])
  parent :contacts
end

crumb :show_reply_contact_message do |message|
  link 'Contact Reply', show_reply_message_path(message.id, source: params[:source])
  if session[:message_base] == 'userid_messages'
    parent :userid_messages, source: params[:source]
  else
    parent :contact_messages, Contact.find(message.source_contact_id), source: params[:source]
  end
end

# ...........................................................Communications

crumb :communications do
  if session[:archived_contacts]
    link 'My Archived Communications', list_archived_communications_messages_path(source: params[:source])
  else
    link 'My Active Communications', communications_messages_path(source: params[:source])
  end
  parent :root
end

crumb :create_communication do |message|
  link 'Create Communication', new_message_path(message)
  if params[:source] == 'original'
    parent :show_communication, message, source: params[:source]
  else
    parent :communications
  end
end

crumb :show_communication do |message|
  link 'Original Communication', message_path(message.id, source: params[:source])
  parent :communications
end

crumb :edit_communication do |message|
  link 'Edit Communication', edit_message_path(message, source: params[:source])
  if params[:source] == 'original'
    parent :show_communication, message, source: params[:source]
  else
    parent :communications
  end
end

crumb :select_role do |message|
  link 'Select Role'
  parent :show_communication, message, source: params[:source]
end

crumb :select_individual do |message|
  link 'Select Individual'
  parent :select_role, message, source: params[:source]
end

crumb :create_reply_communication do |message, id|
  link 'Create Reply for Communication', reply_messages_path(message.id, source: 'reply')
  if params[:source] == 'reply'
    if id.blank?
      parent :communications, source: params[:source]
    else
      parent :show_reply_communication, Message.find(id), source: params[:source]
    end
  elsif params[:source] == 'original'
    if session[:original_message_id].blank?
      parent :communications
    else
      parent :show_communication, Message.find(session[:original_message_id]), source: params[:source]
    end
  else
    parent :communications, source: params[:source]
  end
end

crumb :list_reply_communications do |message|
  link 'Communication Replies', reply_messages_path(message, source: params[:source])
  if params[:source] == 'original'
    parent :show_communication, message, source: params[:source]
  elsif params[:source] == 'reply'
    params[:source] = 'original'
    if session[:original_message_id].blank?
      parent :communications
    else
      parent :show_communication, Message.find(session[:original_message_id]), source: params[:source]
    end
  else
    oarent :communications
  end
end

crumb :show_reply_communication do |message|
  link 'Communication Reply', show_reply_message_path(message.id, source: params[:source])
  parent :list_reply_communications, message.source_message_id, source: params[:source]
end
#                                      .....................Messages...............................
crumb :messages do
  if session[:archived_contacts]
    link 'Archived Messages', list_archived_messages_path(source: params[:source])
  else
    link 'Active Messages', messages_path(source: params[:source])
  end
  parent :root
end

crumb :show_message do |message|
  link 'Original Message', message_path(message.id, source: params[:source])
  if params[:source] == 'original' || params[:source] == 'reply'
    parent :messages
  elsif message.source_feedback_id.present?
    feedback = Feedback.id(message.source_feedback_id).first
    parent :feedback_messages, feedback
  elsif message.source_contact_id.present?
    contact = Contact.id(message.source_contact_id).first
    parent :contact_messages, contact
  else
    parent :messages
  end
end

crumb :create_message do |message|
  link 'Create Message', new_message_path(message)
  if params[:source] == 'original'
    parent :show_message, message, source: params[:source]
  else
    parent :messages
  end
end

crumb :edit_message do |message|
  link 'Edit Message', edit_message_path(message, source: params[:source])
  if params[:source] == 'original'
    parent :show_message, message, source: params[:source]
  else
    parent :messages
  end
end

crumb :create_message_reply do |message, id|
  link 'Create Reply', reply_messages_path(message.id, source: 'reply')
  if params[:source] == 'reply'
    if id.blank?
      parent :messages, source: params[:source]
    else
      parent :show_reply_message, Message.find(id), source: params[:source]
    end
  elsif params[:source] == 'original'
    if session[:original_message_id].blank?
      parent :messages, source: params[:source]
    else
      parent :show_message, Message.find(session[:original_message_id]), source: params[:source]
    end
  else
    parent :messages, source: params[:source]
  end
end

crumb :reply_messages_list do |message|
  link 'Reply Messages', reply_messages_path(message, source: params[:source])
  if session[:message_base] == 'userid_messages'
    if params[:source] == 'original'
      if session[:original_message_id].blank?
        parent :userid_messages
      else
        parent :show_userid_message, Message.find(session[:original_message_id]), source: params[:source]
      end
    else
      parent :userid_messages
    end
  elsif params[:source] == 'original'
    parent :show_message, message, source: params[:source]
  elsif params[:source] == 'reply'
    params[:source] = 'original'
    if session[:original_message_id].blank?
      parent :messages
    else
      parent :show_message, Message.find(session[:original_message_id]), source: params[:source]
    end
  else
    parent :messages
  end
end

crumb :show_reply_message do |message|
  link 'Reply Message', show_reply_message_path(message.id, source: params[:source])
  parent :reply_messages_list, message.source_message_id, source: params[:source]
end

crumb :message_form_for_selection do
  link 'Form for Selection'
  if session[:syndicate].present?
    parent :message_to_syndicate
  else
    parent :messages
  end
end

crumb :select_recipients do |message|
  link 'Select Recipients', select_recipients_messages_path(message, source: params[:source])
  case session[:message_base]
  when 'syndicate'
    parent :show_syndicate_message, message, source: params[:source]
  when 'general'
    parent :show_message, message, source: params[:source]
  else
    parent :show_message, message, source: params[:source]
  end
end
# .........................................................................Syndicate messages
crumb :syndicate_messages do
  if session[:archived_contacts]
    link 'Archived Syndicate Messages', list_archived_syndicate_messages_path(source: params[:source])
  else
    link 'Active Syndicate Messages', list_syndicate_messages_path(source: params[:source])
  end
  parent :syndicate_options, session[:syndicate]
end

crumb :create_syndicate_message do |message|
  link 'Create Syndicate Message', new_message_path(message)
  if params[:source] == 'original'
    parent :show_syndicate_message, message, source: params[:source]
  else
    parent :syndicate_messages
  end
end

crumb :show_syndicate_message do |message|
  link 'Original Syndicate Message', message_path(message.id, source: params[:source])
  parent :syndicate_messages
end

crumb :edit_syndicate_message do |message|
  link 'Edit Syndicate Message', edit_message_path(message, source: params[:source])
  if params[:source] == 'original'
    parent :show_syndicate_message, message, source: params[:source]
  else
    parent :syndicate_messages
  end
end

crumb :select_syndicate_role do |message|
  link 'Form for Role Selection'
  parent :show_syndicate_message, message, source: params[:source]
end

crumb :select_syndicate_individual do |message|
  link 'Form for Individual Selection'
  parent :select_syndicate_role, message, source: params[:source]
end

crumb :create_reply_syndicate_message do |message, id|
  link 'Create Reply for Syndicate Message', reply_messages_path(message.id, source: 'reply')
  if params[:source] == 'reply'
    if id.blank?
      parent :syndicate_messages, source: params[:source]
    else
      parent :show_syndicate_reply_message, Message.find(id), source: params[:source]
    end
  elsif params[:source] == 'original'
    if session[:original_message_id].blank?
      parent :syndicate_messages, source: params[:source]
    else
      parent :show_syndicate_message, Message.find(session[:original_message_id]), source: params[:source]
    end
  else
    parent :syndicate_messages, source: params[:source]
  end
end

crumb :list_replies_to_syndicate_message do |message|
  link 'Replies to Syndicate Message', reply_messages_path(message, source: params[:source])
  if params[:source] == 'original'
    parent :show_syndicate_message, message, source: params[:source]
  elsif params[:source] == 'reply'
    params[:source] = 'original'
    if session[:original_message_id].blank?
      parent :syndicate_messages, source: params[:source]
    else
      parent :show_syndicate_message, Message.find(session[:original_message_id]), source: params[:source]
    end
  else
    parent :syndicate_messages, source: params[:source]
  end
end

crumb :show_syndicate_reply_message do |message|
  link 'Syndicate Reply Message', show_reply_message_path(message.id, source: params[:source])
  parent :list_replies_to_syndicate_message, message.source_message_id, source: params[:source]
end
# ....................................................Userid Messages
crumb :userid_messages do
  link 'My Messages', userid_messages_path(source: params[:source])
  parent :root
end

crumb :show_userid_message do |message|
  link 'Original Message', message_path(message, source: params[:source])
  parent :userid_messages
end

crumb :create_reply_userid_message do |message, id|
  link 'Create Reply for a Message', reply_messages_path(message.id, source: 'reply')
  if params[:source] == 'reply'
    if id.blank?
      parent :userid_messages
    else
      parent :show_userid_reply_message, Message.find(id), source: params[:source]
    end
  elsif params[:source] == 'original'
    if session[:original_message_id].blank?
      parent :userid_messages
    else
      parent :show_userid_message, Message.find(session[:original_message_id]), source: params[:source]
    end
  else
    parent :userid_messages, source: params[:source]
  end
end

crumb :userid_reply_messages do |message|
  link 'Replies to Messages', userid_reply_messages_path(message, source: params[:source])
  if params[:source] == 'original'
    parent :show_userid_message, message, source: params[:source]
  elsif params[:source] == 'reply'
    params[:source] = 'original'
    if session[:original_message_id].blank?
      parent :userid_messages
    else
      parent :show_userid_message, Message.find(session[:original_message_id]), source: params[:source]
    end
  else
    parent :userid_messages
  end
end

crumb :show_userid_reply_message do |message|
  link 'Message Reply', show_reply_message_path(message.id, source: params[:source])
  parent :userid_reply_messages, message.source_message_id, source: params[:source]
end
#............................................................Denominations......................................
crumb :denominations do
  link 'Denominations', denominations_path
  parent :root
end
crumb :show_denomination do |denomination|
  link 'Show Denomination', denomination_path(denomination)
  parent :denominations
end
crumb :edit_denomination do |denomination|
  link 'Edit Denomination', edit_denomination_path(denomination)
  parent :show_denomination, denomination
end
crumb :create_denomination do |denomination|
  link 'Create Denomination', new_denomination_path(denomination)
  parent :denominations
end
crumb :select_attic_files do
  link 'Select Userid', select_userid_attic_files_path
  parent :root
end
crumb :show_attic_files do |user|
  link 'Listing of Attic Files', attic_files_path(user)
  parent :select_attic_files
end
crumb :countries do
  link 'Countries', countries_path
  parent :root
end
crumb :show_countries do |country|
  link 'Show Country', country_path(country)
  parent :countries
end
crumb :new_county do |county|
  link 'Activate County', new_county_path
  parent :counties
end
crumb :edit_country do |country|
  link 'Edit Country', edit_country_path(country)
  parent :show_countries, country
end
crumb :counties do
  link 'Counties', counties_path
  parent :root
end
crumb :show_counties do |county|
  link 'Show County', county_path(county)
  parent :counties
end
crumb :edit_county do |county|
  link 'Edit County', edit_county_path(county)
  parent :show_counties, county
end
crumb :syndicates do
  link 'Syndicates', syndicates_path
  parent :root
end
crumb :show_syndicate do |syndicate|
  link 'Show Syndicate', syndicate_path(syndicate)
  parent :syndicates
end
crumb :edit_syndicate do |syndicate|
  link 'Edit Syndicate', edit_syndicate_path(syndicate)
  parent :show_syndicate, syndicate
end
crumb :create_syndicate do |syndicate|
  link 'Create Syndicate', new_syndicate_path(syndicate)
  parent :syndicates
end

crumb :listing_of_zero_year_files do
  if session[:syndicate].present?
    link "Listing of Zero Year files", zero_selection_manage_syndicates_path(option: 'Review Batches with Zero Dates')
    parent :syndicate_options, session[:syndicate]
  elsif session[:county].present?
    link "Listing of Zero Year files", zero_selection_manage_counties_path(option: 'Review Batches with Zero Dates')
    parent :county_options, session[:county]
  else
    link "Listing of Zero Year files", display_my_own_zero_years_files_path
    parent :files, file
  end
end

crumb :listing_of_zero_year_entries do |file|
  link "Listing of Zero Year Entries", zero_year_freereg1_csv_file_path(id: "#{file.id}")
  parent :listing_of_zero_year_files
end

crumb :show_zero_year_entry do |entry, file|
  @zero_year = 'true'
  link 'Show Zero Year Entry', freereg1_csv_entry_path(entry, 'zero_listing' => @zero_year)
  parent :listing_of_zero_year_entries, file
end

crumb :edit_zero_year_entry do |entry,file|
  link 'Edit Zero Year Entry', edit_freereg1_csv_entry_path(entry)
  parent :show_zero_year_entry, entry,file
  parent :listing_of_zero_year_entries, file if request.referer.match(/zero_year/) unless request.referer.nil?
end


# breadcrumbs from 'assignments'
crumb :my_own_assignments do |user|
  link "#{user.userid} Assignments", my_own_assignment_path(user)
  parent :root
end

# from 'assignments' => 'list image groups under my syndicate'
crumb :request_assignments_by_syndicate do |user|
  link 'Image Groups Under My Syndicate', my_list_by_syndicate_image_server_group_path(user)
  parent :my_own_assignments, user
end

# from 'assignments' => 'Image Groups Available for Allocation(By County)'
# from 'all allocated image groups' => 'Image Groups Available for Allocation(By County)'
crumb :request_assignments_by_county do |user,county|
  link "Image Groups Available for Allocation(#{county})", my_list_by_county_image_server_group_path(county)
  parent :syndicate_available_groups_by_county_select_county, user
end

# from 'assignments' => 'LS'
crumb :my_own_assignment do |user|
  link 'Assignment'
  parent :my_own_assignments, user
end




# breadcrumbs from 'manage syndicates' => 'manage images'
crumb :syndicate_manage_images do |syndicate|
  link 'All Allocated Image Groups', manage_image_group_manage_syndicate_path(syndicate)
  parent :syndicate_options, session[:syndicate]
end

# from 'manage syndicates' => 'manage images' => 'image groups available for allocation'
crumb :syndicate_available_groups_by_county_select_county do |user|
  link 'Select County', select_county_assignment_path

  if session[:my_own]
    parent :my_own_assignments, user
  else
    parent :syndicate_manage_images, session[:syndicate]
  end
end

# from 'manage syndicates' => 'manage images' => 'list assignment by userid'
crumb :syndicate_all_assignments_select_user do |syndicate|
  link 'Select User', select_user_assignment_path(session[:syndicate], :assignment_list_type=>'all')
  parent :syndicate_manage_images, session[:syndicate]
end

crumb :syndicate_all_assignments do |syndicate|
  link 'List User Assignments', list_assignments_by_syndicate_coordinator_assignment_path(session[:syndicate], :assignment_list_type=>'all')
  if session[:list_user_assignments] == true
    parent :syndicate_all_assignments_select_user, session[:syndicate]
  else
    parent :syndicate_manage_images, session[:syndicate]
  end
end

crumb :syndicate_all_assignment do |syndicate|
  link 'List User Assignment'
  if session[:list_user_assignments] == true
    parent :syndicate_all_assignments, session[:syndicate]
  else
    parent :syndicate_manage_images, session[:syndicate]
  end
end

crumb :syndicate_all_reassign do |syndicate|
  link 'Re_assign Assignment'
  parent :syndicate_all_assignments, session[:syndicate]
end

# from 'manage syndicate' => 'manage images' => 'list fully transcribed groups'
crumb :fully_transcribed_groups do |syndicate|
  link 'List Fully Transcribed Groups', list_fully_transcribed_group_manage_syndicate_path(session[:syndicate])
  parent :syndicate_manage_images, session[:syndicate]
end

# from 'manage syndicate' => 'manage images' => 'list fully reviewed groups'
crumb :fully_reviewed_groups do |syndicate|
  link 'List Fully Reviewed Groups', list_fully_reviewed_group_manage_syndicate_path(session[:syndicate])
  parent :syndicate_manage_images, session[:syndicate]
end

# from 'manage syndicates' => 'manage images' => 'List Submitted Transcribe assignment'
crumb :submitted_transcribe_assignments do |syndicate|
  link 'List Submitted_Transcription Assignments', list_submitted_transcribe_assignments_assignment_path(session[:syndicate])
  parent :syndicate_manage_images, session[:syndicate]
end

# from 'manage syndicates' => 'manage images' => 'List Submitted Review Assignment'
crumb :submitted_review_assignments do |syndicate|
  link 'List Submitted_Review Assignments', list_submitted_review_assignments_assignment_path(session[:syndicate])
  parent :syndicate_manage_images, session[:syndicate]
end

crumb :syndicate_image_group_assignments do |user,syndicate,county,register,source,group|
  link 'User Assignments', assignment_path(group)
  parent :image_server_images, user,syndicate,county,register,source,group
end

crumb :syndicate_image_group_assignment do |user,syndicate,county,register,source,group|
  link 'User Assignment'
  parent :syndicate_image_group_assignments, user,syndicate,county,register,source,group
end





# from 'manage counties' => 'Manage Images'
crumb :county_manage_images do |county, browse_source|
  if browse_source.nil?
    link 'All Sources', selection_active_manage_counties_path(:option =>'Manage Images')
  else
    link 'All Sources', selection_active_manage_counties_path(:option => 'Manage Images', :anchor => browse_source)
  end
  parent :county_options, session[:county]
end

# from 'manage counties' => 'Manage Images' => 'List All Image Groups'
crumb :county_manage_images_selection do |county, browse_source|
  case session[:image_group_filter]
  when 'all'
    link 'List All Image Groups', manage_image_group_manage_county_path
  when 'unallocate'
    link 'List Unallocated Image Groups', manage_unallocated_image_group_manage_county_path
  when 'allocate request'
    link 'List Allocate Request Image Groups', manage_allocate_request_image_group_manage_county_path
  when 'completion_submitted'
    link 'List Completion Submitted Allocations', manage_completion_submitted_image_group_manage_county_path
  when 'syndicate'
    link 'Image Groups Allocated by Syndicate', sort_image_group_by_syndicate_path(county)
  when 'place'
    link 'Image Groups Allocated by Place', sort_image_group_by_place_path
  when 'uninitialized'
    link 'List Unitialized Sources', uninitialized_source_list_path(county)
  end
  parent :county_manage_images, session[:county], browse_source
end

# from 'register' => Sources        (is taken out right now)
crumb :image_sources do |county, place, church, register|
  link 'Sources', index_source_path(register)
  parent :show_register, county, place, church, register
end

crumb :new_image_source do |register, source|
  link 'Create New Source'
  parent :image_sources, register
end

# breadcrumb for image_source
crumb :show_image_source do |register,source|
  case source.source_name
  when 'Image Server'
    link 'Image Server', source_path(source)
    if session[:manage_user_origin] == 'manage syndicate'
      # from 'manage syndicates' => 'Manage Images' => 'List Fully Reviewed/Transcribed Groups'
      case session[:image_group_filter]
      when 'fully_transcribed'
        parent :fully_transcribed_groups, session[:syndicate]
      when 'fully_reviewed'
        parent :fully_reviewed_groups, session[:syndicate]
      else
        parent :syndicate_manage_images, session[:syndicate]
      end
    else
      parent :county_manage_images_selection, session[:county], source.id.to_s
    end
  when 'Other Server1'
    church = register.church
    place = church.place
    county = place.county
    link 'Other Server1', source_path(source)
    parent :image_sources, county, place, church, register
  when 'Other Server2'
    church = register.church
    place = church.place
    county = place.county
    link 'Other Server2', source_path(source)
    parent :images_sources, county, place, church, register
  when 'Other Server3'
    church = register.church
    place = church.place
    county = place.county
    link 'Other Server3', source_path(source)
    parent :image_sources, county, place, church, register
  end
end

crumb :edit_image_source do |register,source|
  link 'Edit Image Server'
  parent :show_image_source, register,source
end

crumb :initialize_image_source do |register,source|
  link 'Initialize Image Server'
  parent :show_image_source, register,source
end

crumb :propagate_image_source do |register,source|
  link 'Propagate Image Server'
  parent :show_image_source, register,source
end





# breadcrumb for Image Server Groups
crumb :image_server_groups do |user,syndicate,county,register,source|
  link 'Image Groups', index_image_server_group_path(source)
  parent :show_image_source, register,source
end

crumb :allocate_image_server_group do |user,syndicate,county,register,source,group|
  link 'Allocate Image Group'
  parent :image_server_groups, user,syndicate,county,register,source
end

crumb :new_image_server_group do |user,syndicate,county,register,source,group|
  link 'Create Image Group'
  parent :image_server_groups, user,syndicate,county,register,source
end

crumb :initialize_image_server_group do |user,syndicate,county,register,source,group|
  link 'Initialize Image Group'
  parent :image_server_groups, user,syndicate,county,register,source
end


crumb :show_image_server_group do |user,syndicate,county,register,source,group|
  link 'Image Group', image_server_group_path(group)

  if session[:from_source] == true
    parent :image_server_groups, user,syndicate,county,register,source
  else
    # image group from list assignments result
    if !session[:assignment_filter_list].nil? && !session[:assignment_filter_list].empty?
      case session[:assignment_filter_list]
      when 'syndicate'        # from Assignments => 'List Image Groups Under My Syndicate'
        parent :request_assignments_by_syndicate, user
      when 'county'           # from 'Image Groups Available for Allocation(county)'
        parent :request_assignments_by_county, user,syndicate
      end
      # image groups from list groups result
    else
      if session[:manage_user_origin] == 'manage syndicate'
        case session[:image_group_filter]
        when 'fully_transcribed'
          parent :fully_transcribed_groups
        when 'fully_reviewed'
          parent :fully_reviewed_groups
        else
          parent :syndicate_manage_images
        end
      elsif session[:manage_user_origin] == 'manage county'
        parent :county_manage_images_selection, register, source
      end
    end
  end
end

crumb :edit_image_server_group do |user,syndicate,county,register,source,group|
  link 'Edit Image Group'
  parent :show_image_server_group, user,syndicate,county,register,source,group
end

crumb :upload_image_server_group do |user,syndicate,county,register,source,group|
  link 'Upload Images Report'
  parent :show_image_server_group, user,syndicate,county,register,source,group
end




# breadcrumb for Image Server Images
crumb :image_server_images do |user,syndicate,county,register,source,group|
  link 'Images', index_image_server_image_path(group)
  parent :show_image_server_group, user,syndicate,county,register,source,group
end

crumb :move_image_server_image do |user,syndicate,county,register,source,group,image|
  link 'Move Images'
  parent :image_server_images, user,syndicate,county,register,source,group
end

crumb :propagate_image_server_image do |user,syndicate,county,register,source,group,image|
  link 'Propagate Images'
  parent :image_server_images, user,syndicate,county,register,source,group
end

crumb :reassign_image_server_image do |user,syndicate,county,register,source,group,image|
  link 'Reassign Images'
  parent :image_server_images, user,syndicate,county,register,source,group
end

crumb :show_image_server_image do |user,syndicate,county,register,source,group,image|
  link 'Image', image_server_image_path(image)
  parent :image_server_images, user,syndicate,county,register,source,group
end

crumb :edit_image_server_image do |user,syndicate,county,register,source,group,image|
  link 'Edit Image'
  parent :show_image_server_image, user,syndicate,county,register,source,group,image
end

# breadcrumb for GAP
crumb :gaps do |user, syndicate, county, register, source|
  link 'GAPs', index_gap_path(source)
  parent :show_image_source, register,source
end

crumb :show_gap do |user,syndicate,county,register,source|
  link 'GAP'
  parent :gaps, user,syndicate,county,register,source
end

crumb :new_gap do |user,syndicate,county,register,source|
  link 'Create New GAP'
  parent :gaps, user,syndicate,county,register,source
end

crumb :edit_gap do |user,syndicate,county,register,source|
  link 'Edit GAP'
  parent :gaps, user,syndicate,county,register,source
end

crumb :gap_reasons do
  link 'GAP Reasons', gap_reasons_path
  parent :root
end

crumb :show_gap_reason do |gap_reason|
  link 'Show GAP Reason', gap_reason_path(gap_reason)
  parent :gap_reasons
end

crumb :edit_gap_reason do |gap_reason|
  link 'Edit GAP Reason', edit_gap_reason_path(gap_reason)
  parent :show_gap_reason, gap_reason
end

crumb :create_gap_reason do |gap_reason|
  link 'Create GAP Reason', new_gap_reason_path(gap_reason)
  parent :gap_reasons
end

crumb :search_query_report do
  link 'Search Performance', search_query_report_path
  parent :root
end

crumb :show_search_query do |query|
  link 'Search Query Report', show_query_search_query_path(query)
  parent :search_query_report
end

crumb :search_query_analysis do |query|
  link 'Search Query Report', analyze_search_query_path(query)
  parent :search_query_report
end

crumb :application_server_selection do
  link 'Select Application Server Combination', select_app_and_server_software_versions_path
  parent :root
end

crumb :software_updates do
  link 'Software Update History', software_versions_path
  parent :application_server_selection
end

crumb :software_commitments do
  link 'Software commitments', commitments_software_versions_path
  parent :software_updates
end

crumb :edit_software_version do
  link 'Edit Software Version', edit_software_version_path
  parent :software_updates
end


# ...................................FreeCEN>>>>>>>>>>>>>>>>>>>>>>>>>>

crumb :freecen_pieces do |county|
  link 'FreeCen Pieces', freecen_pieces_path(county: county)
  parent :county_options, session[:county]
end

crumb :show_freecen_piece do |file|
  link 'FreeCen Pieces', freecen_piece_path(file.id)
  parent :freecen_pieces, session[:county]
end

crumb :freecen1_fixed_dat_entry do |file|
  link 'FreeCen1 Fixed DAT Entry', freecen1_fixed_dat_entry_path(session[:county])
  parent :freecen1_fixed_dat_file, file, session[:county]
end

crumb :freecen1_fixed_dat_file do |file|
  link 'FreeCen1 Fixed DAT File', freecen1_fixed_dat_file_path(file)
  parent :freecen_pieces, session[:county], session[:page]
end

crumb :manage_places do |county|
  link 'FreeCen Places',  places_path
  parent :county_options, session[:county]
end

crumb :show_freecen_place do |county, place|
  link 'FreeCen Place', place_path(place)
  if session[:manage_places]
    parent :manage_places, session[:county]
  else
    parent :freecen_pieces, session[:county], session[:page]
  end
end

crumb :freecen1_vld_files do |county, page|
  link 'FreeCen1 VLD Files', freecen1_vld_files_path(county: county, page: page)
  parent :county_options, county
end

crumb :freecen1_vld_file do |county, file|
  link 'FreeCen1 VLD File', freecen1_vld_file_path(id: file, county: county)
  parent :freecen1_vld_files, county, session[:file_page]
end

crumb :freecen1_vld_entries do |file, page|
  link 'FreeCen1 VLD Entries', freecen1_vld_entries_path(file: file, page: page)
  parent :freecen1_vld_file, session[:county], file
end

crumb :freecen1_vld_entry do |county, file|
  link 'FreeCen1 VLD Entry', freecen1_vld_entry_path(id: file, county: county)
  parent :freecen1_vld_entries, session[:freecen1_vld_file], session[:entry_page]
end

# crumb :projects do
#   link 'Projects', projects_path
# end

# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link 'Issues', project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).
