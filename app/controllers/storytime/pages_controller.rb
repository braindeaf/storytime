require_dependency "storytime/application_controller"

module Storytime
  class PagesController < ApplicationController
    before_action :load_page

    def show
      if params[:preview].nil? && params[:id].present? && !@page.nil? && params[:id] != @page.slug
        return redirect_to @page, :status => :moved_permanently
      end

      #allow overriding in the host app
      slug = @page.nil? ? ActionController::Base.helpers.sanitize(params[:id]) : @page.slug

      potential_templates = [
        "storytime/#{@current_storytime_site.custom_view_path}/pages/#{slug}",
        "storytime/#{@current_storytime_site.custom_view_path}/pages/show",
        "storytime/pages/#{slug}",
        "storytime/pages/show",
      ].each do |template|
        if lookup_context.template_exists?(template)
          render template
          return
        end
      end
    end

  private

    def load_page
      @page = if params[:preview]
        page = Post.find_preview(params[:id])
        page.content = page.autosave.content
        page.preview = true
        page
      elsif Post.friendly.exists? params[:id]
        Post.published.friendly.find(params[:id])
      else
        nil
      end
      redirect_to "/", status: :moved_permanently if @page == current_storytime_site(request).homepage
    end

    def set_layout
      return super if params[:id].blank?
      
      path_segments = params[:id].split("/")

      if path_segments.length > 1
        path_segments.pop

        potential_layout_dirs = [
          "storytime/#{@current_storytime_site.custom_view_path}/layouts",
          "storytime/layouts",
          "layouts",
        ].each do |dir|
          path_segments.map.with_index do |segment, i|
            potential_layout = "#{dir}/#{path_segments[0..i].join("/")}"
            return potential_layout if lookup_context.template_exists?(potential_layout)
          end
        end
      end

      super
    end

  end
end
