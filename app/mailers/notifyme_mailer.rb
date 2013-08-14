class NotifymeMailer < ActionMailer::Base
  default :from => "akorolex@example.com"
  default :to => "akorolex@yahoo.com"
  def fast_notify(recs)
    @recs = recs
    mail(:subject => "Notification")
  end

end
