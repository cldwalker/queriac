module SharedHelper
  #Permission methods
  def command_owner?(command=@command)
    logged_in? && command.created_by?(current_user)
  end
  
  def admin?
    (logged_in? && current_user.is_admin?)
  end
  
  def command_owner_or_admin?(command=@command)
    command_owner?(command) || admin?
  end

  #used where load_valid_user() and/or @user defined
  def current_user?(user=@user)
    logged_in? && current_user == user
  end
  
  def can_view_queries?
    user_command_owner? || @user_command.public_queries?
  end
  
  def user_command_owner?(user_command=@user_command)
    user_command.owned_by?(current_user)
  end
  
  def user_command_owner_or_admin?(user_command=@user_command)
    user_command_owner?(user_command) || admin?
  end
  
  def subscribe_action?
    self.is_a?(ApplicationController) ? self.action_name == 'subscribe' : (@controller && @controller.action_name == 'subscribe')
  end
  #misc methods
  
  def feed_icon_tag(title, url)
    add_rss_feed(url, title)
    link_to image_tag('icons/feed.png', :size => '14x14', :alt => "Subscribe to #{title}", :style => 'margin-left:12px;'), url
  end
  
  def clear_rss_feed
    @feed_icons = []
  end
  
  def add_rss_feed(rss_url=nil,title=nil)
    #correct way since it's compatible with route definitions
    # rss_url ||= {}.merge(:format=>'rss')
    #hack: contructing rss feeds assuming path ends with .rss
    #necessary for user_commands actions
    rss_url ||= request.url + ".rss"
    (@feed_icons ||= []) << { :url => rss_url, :title => title }
  end

  def get_bot_param_for(action)
    action_salt = Digest::SHA1.hexdigest "--#{action}--"
    @crypted_param = Digest::SHA1.hexdigest "--#{action_salt}--#{Date.today}--"
    @crypted_param
  end
end