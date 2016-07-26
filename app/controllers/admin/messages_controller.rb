class Admin::MessagesController < Admin::AdminApplicationController
  
  before_action :set_message, only: [:show, :edit, :update, :destroy]

  # def index
  #   @messages = Message.all
  # end
  #
  # def new
  #   @message = Message.new
  # end
  #
  # def edit
  # end
  
  def show
  end

  def create
    @message = Message.new(message_params)

    if @message.save
      redirect_to admin_messages_path, notice: 'Message was successfully created.'
    else
      render :new
    end
  end

  def update
    if @message.update(message_params)
      redirect_to @message, notice: 'Message was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @message.destroy
    redirect_to messages_url, notice: 'Message was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def message_params
      params.require(:message).permit(:status)
    end
end
