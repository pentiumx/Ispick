class ContactController < ApplicationController
  def new
    @message = Message.new
    render 'notifications_mailer/new'
  end

  def create
    @message = Message.new(message_params)

    # TODO: display notice in the page when it fails to send data.
    if @message.valid?
      NotificationsMailer.new_message(@message).deliver
      redirect_to(home_users_path, :notice => "Message was successfully sent.")
    else
      flash.now.alert = "Please fill all fields."
      render 'notifications_mailer/new'
    end
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:name, :email, :subject, :body, :id)
    end
end
