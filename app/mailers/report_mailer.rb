class ReportMailer < ActionMailer::Base
  default from: "from@example.com"
  
  def report(user, reports)
  	@reports = reports
  	@council = Council.find(user.councilid)
  	mail(:to => user.email, :from => "admin@ratemyplace.org.uk", :subject => "Your Ratemyplace weekly report for #{@council.name}")
  end
end
