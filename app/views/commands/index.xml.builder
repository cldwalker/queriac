atom_feed do |feed|
  feed.title "#{@user.login}'s Queriac Commands"
  feed.base_url("http://queri.ac/#{@user.login}")
	feed.schema_date(Time.now - 2.seconds)
	
  for command in @commands
	  feed.entry(command) do |entry|
	    entry.name(command.name)
			entry.link("http://queri.ac/#{@user.login}/#{command.keyword}/show")
	    entry.keyword(command.keyword)
	    entry.url(command.url)
			entry.tags(command.tag_string)
	  end
  end
end