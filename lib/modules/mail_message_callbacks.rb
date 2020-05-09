# frozen_string_literal: true

module MailMessageCallBacks
  # rubocop:disable Naming/MemoizedInstanceVariableName
  def deliver
    @email_was_delivered ||= run_after_send(super)
  end

  def deliver!
    @email_was_delivered ||= run_after_send(super)
  end
  # rubocop:enable Naming/MemoizedInstanceVariableName

  def after_send(&block)
    @after_send_actions ||= []
    @after_send_actions << block
  end

  def run_after_send(result)
    unless called
      (@after_send_actions || []).each do |block|
        block.call(result)
      rescue
        logger.error $!.message
        logger.error $!.backtrace
      end
    end
    result
  end

  def called
    val = !!@called
    @called ||= true
    val
  end
end

Mail::Message.prepend MailMessageCallBacks
