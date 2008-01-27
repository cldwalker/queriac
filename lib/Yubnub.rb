require 'rubygems'
require 'hpricot'
require 'open-uri'

module Yubnub
  
  def self.steal_eggs

    yubnub = User.find_by_login "yubnub"

    # Get golden egg command keywords
    commands = []
    1.upto(12) do |page|
      doc = Hpricot(open("http://yubnub.org/kernel/golden_eggs?page=#{page}"))

      doc.search("//a[@class='description hint']").each do |link|
        cmd = link.attributes['href'].split("=").last
        commands << cmd
      end

    end

    # Pull up each command page and gather its info
    commands.each do |cmd|

      doc = Hpricot(open("http://yubnub.org/kernel/man?args=#{cmd}"))

      url = doc.search("//span[@class='muted']").first.inner_html
  
      description = doc.search("//pre").first.inner_html
  
      puts cmd
      puts url
      puts description
      puts "\n\n"  

      
      yubnub.commands.create(
        :name => cmd, 
        :keyword => cmd,
        :url => url,
        :description => description
      ) if cmd =~ /(?=.*([a-z]|[A-Z]))/
      # g.update_tags("google"); 
    end
  end
end