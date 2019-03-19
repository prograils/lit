class Lit::Base < ActiveRecord::Base
  self.abstract_class = true

  before_save :mark_for_retry

  attr_accessor :retried_created, :retried_updated

  def mark_for_retry
    @will_retry_create = true
  end

  after_rollback :retry_lit_model_save

  def rolledback_after_insert?
    persisted? && @was_saved_with_insert && @was_rolled_back
  end

  def rolledback_after_update?
    persisted? && @was_saved_with_update && @was_rolled_back
  end

  private

  def create_or_update(*args, &block)
    @was_saved_with_insert = true if new_record?
    @was_saved_with_update = true if persisted?

    super
  end

  def retry_lit_model_save
    return if @was_rolled_back
    @was_rolled_back = true
    do_retry if instance_variable_defined?(:@will_retry_create) && @will_retry_create
  end

  def do_retry
    if !retried_created
      self.retried_created = true
      if rolledback_after_insert?
        self.class.create! attributes.merge(retried_created: true)
      end
    elsif !retried_updated
      self.retried_updated = true
      if rolledback_after_update?
        update_columns(attributes)
      end
    end
  end

end
