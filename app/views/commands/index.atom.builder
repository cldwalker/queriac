atom_feed do |feed|
  feed.title "Kommandz"
  feed.link('http://queri.ac/')
  for command in @commands
	  feed.entry(command) do |entry|
	    entry.name(command.name)
	    entry.keyword(command.keyword)
	    entry.url(command.url)
	  end
  end
end