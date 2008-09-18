xml.instruct! :xml, :version=>"1.0"
set_rss_header_defaults
xml.rss(:version => '2.0', 'xmlns:media'.to_sym => 'http://search.yahoo.com/mrss/', 'xmlns:dc'.to_sym => 'http://dublincore.org/documents/dcmi-namespace/') do
  xml.channel do
    xml.title("Latest Commands on queri.ac")
    xml.link(commands_url)
    xml.description("Latest commands on queri.ac")
    xml.language('en-us')
    
    @commands.each do |c|
      
      xml.item do
        xml.title(c.name)
        xml.description do 
          xml.cdata! <<-END
          #{command_link(c)}  				
          <p>
          <b>Description</b>
          #{truncate(command_description(c), 500)}
  				</p>
          END
        end
      
        xml.pubDate(c.created_at.to_s(:rfc822))
      end
    end
  end
end