# spec/controllers/resources_controller_spec.rb

require 'rails_helper'

RSpec.describe ResourcesController, :type => :controller do
  include Spec::Contexts::Controllers::ResourcesContexts

  include Spec::Examples::Controllers::ResourcesExamples
  include Spec::Examples::Controllers::RenderingExamples

  describe '#show' do
    def perform_action
      get :show, :directories => path
    end # method perform_action

    describe 'with an empty path', :path => :empty do
      expect_behavior 'renders template', :show

      expect_behavior 'assigns directories'
    end # describe

    describe 'with an invalid path', :path => :invalid_directory do
      expect_behavior 'redirects to the last found directory'
    end # describe

    describe 'with a valid path to a blog', :path => :valid_feature do
      let(:resource) { create(:blog, :directory => directories.last) }

      expect_behavior 'renders template', :show

      expect_behavior 'assigns directories'

      expect_behavior 'assigns the resource'
    end # describe

    describe 'with a valid path to a blog post', :path => :valid_feature do
      let(:blog)     { create(:blog, :directory => directories.last) }
      let(:resource) { create(:blog_post, :blog => blog, :content => build(:content)) }
      let(:path)     { segments.push(blog.slug, resource.slug).join('/') }

      expect_behavior 'renders template', :show
    end # describe

    describe 'with a valid path to a directory', :path => :valid_directory do
      let(:resource) { directories.last }

      expect_behavior 'renders template', :show

      expect_behavior 'assigns directories'

      expect_behavior 'assigns the resource'
    end # describe

    describe 'with a valid path to a page', :path => :valid_feature do
      let(:resource) { create(:page, :directory => directories.last, :content => build(:content)) }

      expect_behavior 'renders template', :show

      expect_behavior 'assigns directories'

      expect_behavior 'assigns the resource'
    end # describe
  end # describe
end # describe
