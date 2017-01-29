class WelcomeController < ApplicationController
  before_action :authenticate_admin!, only: [:catan]
  def index
  end

  def catan
  end
end
