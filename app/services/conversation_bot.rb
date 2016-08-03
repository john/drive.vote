class ConversationBot

  def initialize convo, message
    @conversation = convo
    @message = message
  end

  def response
    # todo - bot based on lifecycle
    'Hi, thanks for contacting us. Someone will text you momentarily to arrange a ride.'
  end

end