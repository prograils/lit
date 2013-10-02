module Lit
  class LocalizationKeysController < ::Lit::ApplicationController
    before_filter :get_localization_scope, :except=>[:destroy]

    def index
      get_localization_keys
    end

    def starred
      @scope = @scope.where(:is_starred=>true)

      if @scope.respond_to?(:page)
        @scope = @scope.page(params[:page])
      end
      get_localization_keys
      render :action=>:index
    end

    def star
      @localization_key = LocalizationKey.find params[:id].to_i
      @localization_key.is_starred = ! @localization_key.is_starred?
      @localization_key.save
      respond_to :js
    end

    def destroy
      @localization_key = LocalizationKey.find params[:id].to_i
      @localization_key.destroy
      I18n.available_locales.each do |l|
        Lit.init.cache.delete_key "#{l}.#{@localization_key.localization_key}"
      end
      respond_to :js
    end

    private
      def get_localization_scope
        @search_options = params.slice(*valid_keys)
        @search_options[:include_completed] = '1' if @search_options.empty?
        @scope = LocalizationKey.uniq.search(@search_options)
      end

      def get_localization_keys
        key_parts = if @search_options[:key_prefix].present?
                       key_parts = @search_options[:key_prefix].split('.').length
                      else
                       0
                      end
        @prefixes = @scope.uniq.pluck(:localization_key).map{|lk| lk.split('.').shift(key_parts+1).join('.') }.uniq.sort
        if @search_options[:key_prefix].present?
          parts = @search_options[:key_prefix].split('.')
          @parent_prefix = parts[0,parts.length-1].join('.')
        end
        if @scope.respond_to?(:page)
          @localization_keys = @scope.page(params[:page])
        else
          @localization_keys = @scope.all
        end
      end

      def valid_keys
        %w( key include_completed key_prefix )
      end

  end
end
