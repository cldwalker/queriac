class GiveDevelopersAdminAbilities < ActiveRecord::Migration
  def self.up
    if (user = User.find_by_login('zeke'))
      user.update_attribute :is_admin, true
    end
    if (user = User.find_by_login('ghorner'))
      user.update_attribute :is_admin, true
    end
  end

  def self.down
    if (user = User.find_by_login('zeke'))
      user.update_attribute :is_admin, false
    end
    if (user = User.find_by_login('ghorner'))
      user.update_attribute :is_admin, false
    end
  end
end
