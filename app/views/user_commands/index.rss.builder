xml.instruct! :xml, :version=>"1.0"
set_rss_header_defaults
xml.rss(:version => '2.0', 'xmlns:media'.to_sym => 'http://search.yahoo.com/mrss/', 'xmlns:dc'.to_sym => 'http://dublincore.org/documents/dcmi-namespace/') do
  xml.channel do
    xml.title("User Commands on queri.ac")
    xml.link(request.url.gsub('.rss', ''))
    
    description = @user_commands.empty? ? 'No' : (@user ? "#{@user.login}'s" : "All")
		description +=  " #{@command.keyword}" if @command
		description += " user commands "
		description += "tagged with '#{@tags.join("+").gsub("+", "' and '")}'" unless @tags.blank?
		xml.description(description)
    xml.language('en-us')
    
    @user_commands.each do |c|
      
      xml.item do
        xml.title(c.name)
        xml.description do 
          xml.cdata! <<-END
          #{user_command_link(c)}<br/>
  				Created by: #{user_link(c.user)}
          
          <p>
          <b>Description</b>
          #{truncate(command_description(c), 500)}
          
  				</p>
          END
        end
        xml.user(c.user.login)
        xml.tags(c.tag_string)
        xml.pubDate(c.created_at.to_s(:rfc822))
      end
    end
  end
end