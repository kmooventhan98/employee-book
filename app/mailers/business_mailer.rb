class BusinessMailer < ApplicationMailer
  layout false

  def welcome_email(business, owner, temporary_password: nil)
    @business = business
    @owner = owner
    @temporary_password = temporary_password
    @login_url = new_session_url

    from_addr = ENV["MAILER_DEFAULT_FROM"].presence ||
                (ENV["SMTP_USERNAME"].present? ? "KarigarBook <#{ENV['SMTP_USERNAME']}>" : "KarigarBook <welcome@mooventhan.in>")

    mail(
      from: from_addr,
      to: @owner.email_address,
      subject: "🎉 Welcome to KarigarBook — #{@business.name} is Ready!"
    )
  end
end
