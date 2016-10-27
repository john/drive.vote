class Admin::ConversationsController < Admin::AdminApplicationController

  before_action :set_conversation, only: [:show, :messages, :ride_pane, :update_attribute, :close]

  # GET /admin/conversations
  def index
    @conversations = Conversation.where.not(status: :closed)
  end

  # GET /admin/conversations/1
  def show
  end

  # POST /admin/conversations/1/close
  def close
    @conversation.status = :closed
    @conversation.save!
    flash[:notice] = "Conversation closed."
    redirect_back(fallback_location: root_path) and return
  end

  private
  def set_conversation
    @conversation = Conversation.find(params[:id])
  end
end
