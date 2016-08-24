class Admin::ConversationsController < Admin::AdminApplicationController

  before_action :set_conversation, only: [:show, :messages, :ride_pane, :update_attribute, :close]

  # GET /admin/conversations
  def index
    @conversations = Conversation.where.not(status: :closed)
  end

  # GET /admin/conversations/1
  def show
  end

  # GET /admin/conversations/1/messages
  def messages
    render partial: 'messages'
  end

  # GET /admin/conversations/1/form
  def ride_pane
    @zone_driver_count = User.with_role(:driver, @conversation.ride_zone).count
    @available_drivers = @conversation.ride_zone.available_drivers

    if @conversation.ride.present?
      if params[:edit].blank?
        render partial: 'ride_info' # show ride info
      else
        @action =  'Edit'
        @obj = @conversation.ride
        render partial: 'ride_form'
      end

    elsif @conversation.ride.blank? # create ride
      @action =  'Create'
      @obj = @conversation
      render partial: 'ride_form'
    end
  end

  # POST /admin/conversations/1/close
  def close
    @conversation.status = :closed
    @conversation.save!
    redirect_to admin_conversations_url, notice: 'Conversation was closed'
  end

  private
  def set_conversation
    @conversation = Conversation.find(params[:id])
  end
end
