class Lit::Base < ActiveRecord::Base
  self.abstract_class = true

  before_save :mark_for_retry_on_create, on: :create
  before_save :mark_for_retry_on_update, on: :update

  def mark_for_retry_on_create
    @will_retry_create = true
  end

  def mark_for_retry_on_update
    @will_retry_update = true
  end


  after_rollback :retry_lit_model_save

  private

  def retry_lit_model_save
    retry_on_create if @will_retry_create
    retry_on_update if @will_retry_update
  end

  def retry_on_create
    return if @retry_created
    @retry_created = true
    self.class.create attributes
  end

  def retry_on_update
    return if @retry_updated
    @retry_updated = true
    update attributes
  end

  def lit_attribute_will_change
    raise NotImplementedErrror
  end

end