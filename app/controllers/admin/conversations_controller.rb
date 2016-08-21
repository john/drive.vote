class Admin::ConversationsController < Admin::AdminApplicationController

  before_action :set_conversation, only: [:show, :messages, :form, :update_attribute, :close]

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
  def form
    @zone_driver_count = User.with_role(:driver, @conversation.ride_zone).count
    @available_drivers = User.with_role(:driver, @conversation.ride_zone).where(available: true)
    render partial: 'form'
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
