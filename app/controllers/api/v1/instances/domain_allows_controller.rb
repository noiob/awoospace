# frozen_string_literal: true

class Api::V1::Instances::DomainAllowsController < Api::V1::Instances::BaseController
  before_action :require_enabled_api!
  before_action :set_domain_allows

  vary_by '', if: -> { Setting.show_domain_blocks == 'all' }

  def index
    # I don't want to add separate settings so I'm just piggybacking off of the blocks ones
    if Setting.show_domain_blocks == 'all'
      cache_even_if_authenticated!
    else
      cache_if_unauthenticated!
    end

    # render json: @domain_allows, each_serializer: REST::DomainAllowSerializer
    render json: @domain_allows
  end

  private

  def require_enabled_api!
    head 404 unless api_enabled?
  end

  def api_enabled?
    show_domain_blocks_for_all? || show_domain_blocks_to_user?
  end
  
  def show_domain_blocks_to_user?
    Setting.show_domain_blocks == 'users' && user_signed_in? && current_user.functional_or_moved?
  end

  def set_domain_allows
    @domain_allows = DomainAllow.allowed_domains.sort
  end
  
  def show_domain_blocks_for_all?
    Setting.show_domain_blocks == 'all'
  end
end
