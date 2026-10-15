class BusinessMailer < ApplicationMailer
  default from: "KarigarBook Onboarding <welcome@karigarbook.com>"

  def welcome_email(business, owner, temporary_password: nil)
    @business = business
    @owner = owner
    @temporary_password = temporary_password
    @login_url = new_session_url

    mail(
      to: @owner.email_address,
      subject: "🎉 Welcome to KarigarBook — #{@business.name} is Ready!"
    )
  end
end
