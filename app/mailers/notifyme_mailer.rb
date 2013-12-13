class NotifymeMailer < ActionMailer::Base
  default :from => "akorolex@example.com"
  default :to => "akorolex@yahoo.com"
  def fast_notify(recs)
    @recs = recs
    if recs.size > 1
      subject = recs.first.list.Name + "and more..."
    else
      subject = recs.first.list.Name
    end

    mail(:subject => subject)
  end

end
