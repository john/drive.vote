class Admin::ConversationsController < Admin::AdminApplicationController

  before_action :set_conversation, only: [:show, :close]

  # GET /conversations
  def index
    @conversations = Conversation.where.not(status: :closed)
  end

  # GET /conversations/1
  def show
  end

  # POST /conversations/1/close
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
