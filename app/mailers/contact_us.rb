class ContactUs < ActionMailer::Base
  default from: "from@example.com"
  
  def contact_email(mail)
  	@mail = mail
  	
  	if @mail.council != ""
  		@council = Council.find(@mail.council)
  		email = @council.email
  		subject = "Ratemyplace Feedback Form for #{@council.name}"
  	else
  		name = "No particular council"
  		email = "stuart.harrison@lichfielddc.gov.uk"
  		subject = "Ratemyplace Feedback Form"
  	end
  	
  	mail(:to => email, :from => "admin@ratemyplace.org.uk", "reply-to" => mail.email, :subject => subject)
  end
end
