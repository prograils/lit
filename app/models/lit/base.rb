class Lit::Base < ActiveRecord::Base
  self.abstract_class = true

  before_create :mark_for_retry_on_create
  before_update :mark_for_retry_on_update

  attr_accessor :retried_created, :retried_updated

  def mark_for_retry_on_create
    @will_retry_create = true
  end

  def mark_for_retry_on_update
    @will_retry_update = true
  end

  after_rollback :retry_lit_model_save

  private

  def retry_lit_model_save
    retry_on_create if instance_variable_defined?(:@will_retry_create) && @will_retry_create
    retry_on_update if instance_variable_defined?(:@will_retry_update) && @will_retry_update
  end

  def retry_on_create
    return if self.retried_created
    self.retried_created = true
    self.class.create! attributes.merge(retried_created: true)
  end

  def retry_on_update
    return if self.retried_updated
    self.retried_updated = true
    update! attributes.merge(retried_updated: true)
  end

end
