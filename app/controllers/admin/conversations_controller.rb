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
    render partial: 'form'
  end

  # POST /admin/conversations/1/update_attribute?attribute=tk
  def update_attribute
    if(params.has_key?(:attribute_name) && params.has_key?(:attribute_value))
      @conversation.update_attribute( params[:attribute_name], params[:attribute_value] )
    end
    render partial: 'attribute_form', locals: {attribute: params[:attribute_name]}
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
