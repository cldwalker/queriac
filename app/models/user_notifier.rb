class UserNotifier < ActionMailer::Base
  include ActionController::UrlWriter
  default_url_options[:host] = ::HOST
  
  def signup_notification(user)
    setup_email(user)
    @body[:url] = activate_user_url(user.activation_code)
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url] = home_url
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "Queriac Admin <admin@queri.ac>"
      @subject     = "Welcome to Queriac!"
      @sent_on     = Time.now
      @body[:user] = user
    end
end
