class HomeController < ApplicationController
  def index
    get_tags if params[:image_url].present?
  end

  private

  def get_tags
    # Get tags for the image given from Clarifai
    @tag_response = ClarifaiRuby::TagRequest.new.get(params[:image_url])

    # Extract out just the words from the tags
    @tags = @tag_response.tag_images.first.tags_by_words

    # Save the image url so we can access it later
    @image_url = params[:image_url]
  end
end
