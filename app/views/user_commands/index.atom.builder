atom_feed do |feed|
  feed.title "Kommandz"
  feed.link(home_path)
  for ucommand in @user_commands
	  feed.entry(ucommand) do |entry|
	    entry.name(ucommand.name)
	    entry.keyword(ucommand.keyword)
	    entry.url(ucommand.url)
	  end
  end
end