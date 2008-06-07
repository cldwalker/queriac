module CreateSpecHelper
  
  def generate_random_alphanumeric(len=8)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    string = ""
    1.upto(len) { |i| string << chars[rand(chars.size-1)] }
    return string
  end
  
  def random_valid_command_attributes
    seed = generate_random_alphanumeric(3)
    {:url=>"http://#{seed}.com/(q)", :keyword=>seed, :name=>"name for #{seed}"}
  end
  
  def random_valid_user_attributes
    num = rand(10000)
    {:login=>"bozo_#{num}", :email=>"bozo_#{num}@email.com", :password=>'partyfavors', :password_confirmation=>'partyfavors'}
  end
  
  #should use mocks for create_* once controller specs focus only on controller logic
  def create_user(hash={})
    #User.create(random_valid_user_attributes.merge(hash))
    #hacky but done in order to avoid expensive @user.after_create
    user = User.new(random_valid_user_attributes.merge(hash))
    user.send(:create_without_callbacks)
    user
  end
  
  def create_user_command(hash={})
    hash[:command] ||= create_command(hash)
    hash = hash[:command].attributes.slice('url', 'name', 'keyword').merge(hash)
    user = hash[:user] || create_user
    user.user_commands.create(hash)    
  end
  
  def create_command(hash={})
    user = hash[:user] || create_user
    hash = random_valid_command_attributes.merge(hash)
    #these should match what's in after_validation()
    if hash[:kind] == 'shortcut'
      hash[:url].gsub!(DEFAULT_PARAM, '')
    end
    if hash[:bookmarklet]
      hash[:url].sub!('http', 'javascript')
    end
    user.commands.create(hash)
  end
  
  def create_query(hash={})
    ucommand = hash[:user_command] || create_user_command
    user_id = hash[:user_id] || ucommand.user_id
    ucommand.queries.create({:user_id=>user_id, :query_string=>'blah'}.merge(hash))
  end
  
  def create_tag(hash={})
    seed = generate_random_alphanumeric(3)
    Tag.create({:name=>"tag_#{seed}"}.merge(hash))
  end
  
end