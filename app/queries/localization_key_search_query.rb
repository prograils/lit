class LocalizationKeySearchQuery
  def initialize(scope, params = {})
    @scope = scope
    @params = params.to_h
                    .reverse_merge(@scope.default_search_options)
                    .with_indifferent_access
  end

  def perform
    order_data
    search_key_prefix
    search_key
    search_completed
    @scope
  end

  private

  def order_data
    if @params[:order] && order_options.include?(@params[:order])
      column, order = @params[:order].split(' ')
      @scope = @scope.order(
        localization_key_arel[column.to_sym].send(order.to_sym)
      )
    else
      @scope = @scope.ordered
    end
  end

  def search_key_prefix
    return if @params[:key_prefix].blank?
    q = Arel::Nodes.build_quoted("#{@params[:key_prefix]}%")
    @scope = @scope.where(localization_key_col.matches(q))
  end

  def search_key
    return if @params[:key].blank?
    q = Arel::Nodes.build_quoted("%#{@params[:key]}%")
    q_underscore = Arel::Nodes.build_quoted("%#{@params[:key].parameterize.underscore}%")
    cond = search_key_conditions(q, q_underscore)
    @scope = @scope.joins([:localizations]).where(cond)
  end

  def search_key_conditions(query, q_underscore)
    localization_key_col.matches(query).or(
      default_value_col.matches(query).or(
        translated_value_col.matches(query)
      )
    ).or(localization_key_col.matches(q_underscore))
  end

  def search_completed
    return if @params[:include_completed].to_i != 1
    @scope = @scope.not_completed
  end

  def localization_key_col
    localization_key_arel[:localization_key]
  end

  def default_value_col
    localization_arel[:default_value]
  end

  def translated_value_col
    localization_arel[:translated_value]
  end

  def localization_key_arel
    Arel::Table.new 'lit_localization_keys'
  end

  def localization_arel
    Arel::Table.new 'lit_localizations'
  end

  def order_options
    Lit::LocalizationKey.order_options
  end
end
