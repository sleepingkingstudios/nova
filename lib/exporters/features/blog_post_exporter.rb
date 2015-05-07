# lib/exporters/features/blog_post_exporter.rb

require 'exporters/features/feature_exporter'
require 'exporters/resource_exporter'

class BlogPostExporter < ResourceExporter.new(BlogPost)
  include FeatureExporter

  attribute :published_at

  embeds_one :content
end # class