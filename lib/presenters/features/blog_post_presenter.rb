# lib/presenters/features/blog_post_presenter.rb

require 'presenters/feature_presenter'

class BlogPostPresenter < FeaturePresenter
  alias_method :post, :feature

  delegate :blog, :to => :post

  def error_messages
    messages = super.tap { |ary| ary.delete 'Content is invalid' }
    messages += post.content.errors.full_messages.uniq unless post.content.blank?
    messages
  end # method error_messages

  def name
    'Post'
  end # method name

  private

  def icon_name
    :file_o
  end # method icon_name
end # class
