require 'flickraw'
require 'pry'
require 'open-uri'
require 'rmagick'
include Magick

class Solution

  TAG = "cats".freeze

  attr_reader :pic_list

  FlickRaw.api_key = "5448acb0be52ab7d71af7d0498829ea6"
  FlickRaw.shared_secret = "9552411e9c7dd486"

  def initialize
    @tag = TAG
  end

  def solve!
    destination_image.composite!(image_list, rand(0..680), rand(0..680), OverCompositeOp)

    destination_image.write('output.jpeg')
  end

  private

  def request_images
    @request_images ||= flickr.photos.search(tags: TAG, page: 1, per_page: 10)
  end

  def image_size_objects
    @image_size_objects ||= request_images.map do |image_response|
      id = image_response.id
      flickr.photos.getSizes(photo_id: id).find { |size| size.label == 'Small 320' }
    end
  end

  def image_urls
    image_size_objects.map do |image_size|
      image_size["source"]
    end
  end

  def images
    @images ||= image_urls.map do |url|
      Magick::Image.from_blob(open(url).read).first
    end
  end

  def destination_image
    @destination_image ||= Magick::Image.new(1000, 1000)
  end

  def image_list
    @image_list ||= begin
      images.inject(Magick::ImageList.new) do |list, image| 
        list << image 
        list
      end
    end
  end
end

solution = Solution.new
solution.solve!