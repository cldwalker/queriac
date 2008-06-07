atom_feed do |feed|
  feed.title @user ? "#{@user.login}'s Queriac User Commands" : "Queriac User Commands"
  feed.base_url(home_path)
	feed.schema_date(Time.now - 2.seconds)
	
  for ucommand in @user_commands
	  feed.entry(ucommand) do |entry|
	    entry.name(ucommand.name)
			entry.link(public_user_command_path(ucommand))
	    entry.keyword(ucommand.keyword)
	    entry.url(ucommand.url)
			entry.tags(ucommand.tag_string)
	  end
  end
end