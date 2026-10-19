class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_DEFAULT_FROM", "KarigarBook <no-reply@mooventhan.in>")
  layout "mailer"
end
