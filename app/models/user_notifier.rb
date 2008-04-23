class UserNotifier < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @body[:url]  = "http://queri.ac/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://queri.ac/"
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
