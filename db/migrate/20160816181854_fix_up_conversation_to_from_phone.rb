class FixUpConversationToFromPhone < ActiveRecord::Migration[5.0]
  def up
    Conversation.all.each do |conversation|
      unless conversation.messages.empty?
        first_message = conversation.messages.order(:created_at).first
        conversation.update_attributes(to_phone: first_message.to, from_phone: first_message.from)
      end
    end
  end

  def down
    # Do nothing, no reason to reset data back to unclean form
  end
end
