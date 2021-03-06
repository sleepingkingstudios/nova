# app/controllers/admin/features/blog_posts_controller.rb

class Admin::Features::BlogPostsController < Admin::FeaturesController
  # before_action :lookup_blog, :only => %i(index new create)

  private

  def initialize_delegate
    # Insert the #lookup_blog callback in the appropriate point in the callbacks.
    lookup_blog

    super

    @delegate.blog = @blog
  end # method initialize_delegate

  def lookup_blog
    scope = @current_directory.nil? ? Blog.where(:directory_id => nil) : @current_directory.blogs

    @blog = scope.where(:slug => params[:blog]).first

    if @blog.nil?
      router = DirectoryRouter.new @directories.last

      router.route_to!([*@directories.map(&:slug), params[:blog]], @directories, [params[:blog]])
    end # if
  end # method lookup_blog

  def resource_class
    :blog_post
  end # method resource_class
end # class
