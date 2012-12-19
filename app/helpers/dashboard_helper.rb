module DashboardHelper
  
  def partial_for_notification(notification, listing=false)
    
    partial = case notification.class.name.split("::")[-1]
              when 'CallAccepted'
                #listing ? nil : 
                'shared/notification'
              when 'CallRejected'
                #listing ? nil :  
                'shared/notification'
              when 'IncomingCall'
                #listing ? nil :  
                'shared/notification'
              when 'MissedCall'
                #listing ? 'notifies/user_centered' :  
                'notifies/my_content'
              when 'NewBookmark'
                #listing ? 'notifies/user_centered' :  
                'notifies/my_content'
              when 'NewMessage'
                #listing ? 'notifies/user_centered' : 
                'notifies/my_content'
              when 'NewComment'
                #listing ? 'notifies/user_centered' : 
                'notifies/my_content'
              when 'NewFollower'
                #listing ? 'notifies/user_centered' : 
                'notifies/my_content'
              when 'NewRating'
                #listing ? 'notifies/user_centered' : 
                'notifies/my_content'
              when 'MakeRate'
                'notifies/my_content'
              when 'NewKluuu'
                #listing ? nil : 
                'notifies/new_content'
              when 'NewStatus'
                #listing ? nil : 
                'notifies/new_content'
              end
              
    partial ||= 'shared/notification'  # if no partial fits - render debug-partial
    render(:partial => partial, :locals => { :notification => notification } )
  end
  
  
  def link_to_url_for_notification_reason(notification)
    url = notification.path_for_notify
    if block_given? 
      return link_to(url) { yield }
    else
      return link_to( content_tag(:i, ' ', :class => "icon-eye-open"), url, :class => "news-view")
    end
  end

  def css_class_for_klu(klu)
    klu.instance_of?(Kluuu) ? "kluuu" : "no-kluuu"
  end
end
