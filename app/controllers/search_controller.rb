class SearchController < ApplicationController

  include Pagination
  before_action :paginate_params, only: [:search_players]
  before_action :set_sort_params, only: [:search_players]

  def search

  end

  def search_players
    page = @page
    limit = @limit
    @search =  Player.search(include: [:team,:player_statistic]) do |searcher|
      fields = [:name, :club_name]
        searcher.any do
          fulltext search_params[:term], :fields => fields
        end
      searcher.with(:position, "FWD") if search_params[:only_forward] == 'true'
      searcher.with(:position, params[:position]) if params[:position].present?
      searcher.order_by params[:sort_by], params[:sort_direction]
      searcher.facet(:position)
      searcher.paginate :page => page, :per_page => limit
    end
    @players,@total, @total_pages = @search.results, @search.total, @search.results.total_pages
    if params[:facet_call].present?
      render 'search/search_results', layout: false
    else
      render 'search/search'
    end

  end


  def set_sort_params
    params[:sort_by] = (params[:sort_by] || 'name')
    params[:sort_direction] = (params[:sort_direction] || 'asc')
  end

  def search_params
    params.permit( :term, :position, :country, :only_forward, :authenticity_token)
  end

end
