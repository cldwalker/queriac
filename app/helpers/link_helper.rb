module LinkHelper
  def nofollow_link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
    link_to(name, options, (html_options || {}).merge(:rel=>'nofollow'), *parameters_for_method_reference)
  end
  
  def link_to_query(query)
    label = query.query_string.empty? ? "(Command run with no parameters)" : h(query.query_string.ellipsize)
    klass = query.query_string.empty? ? "faded" : ""
    nofollow_link_to(label, h(query.user_command.url_for(query.query_string)), :class => klass, :title=>"Date: #{query.created_at.to_s(:long)}")
  end
  
  #to be used in table listings
  def command_link(command, options={})
    render_favicon_for_command(command) + " " + basic_command_link(command, options.merge(:class=>'iconed')) #+ "- #{any_command_stats(command)}"
  end
  
  def any_command_stats(command)
    %[#{command.public? ? "P": "p"}#{"B" if command.bookmarklet?}#{command.parametric? ? (command.has_options? ? "O": "A") : "S"}]
  end
  
  def basic_command_link(command, options={})
    link_to(h(command.name), command_path(command), :title=>h(truncate(command.url, 200)), :class =>options[:class])
  end
  
  def basic_user_command_link(user_command, options={})
    link_to(h(options[:name_length] ? truncate(user_command.name, options[:name_length]) : user_command.name),
      public_user_command_path(user_command), :title=>h(truncate(user_command.url, 200)), :class=>options[:class])
  end
  
  #to be used in table listings
  def user_command_link(user_command, options={})
    render_favicon_for_command(user_command) + " " + basic_user_command_link(user_command, options.merge(:class=>'iconed'))
  end
  
  def user_link(user)
    link_to(h(user.login), user_home_path(user), :title=>'poop')
  end
  
  def query_user(query)
    query.user ? user_link(query.user) : '--' # + query.user_command.user.login
  end
  
end