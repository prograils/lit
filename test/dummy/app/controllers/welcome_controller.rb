class WelcomeController < ApplicationController
  before_filter :authenticate_admin!, only: [:catan]
  def index
  end

  def catan
  end
end
