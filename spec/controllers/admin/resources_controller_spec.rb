# spec/controllers/admin/resources_controller_spec.rb

require 'rails_helper'

RSpec.describe Admin::ResourcesController, :type => :controller do
  include Spec::Contexts::Controllers::ResourcesContexts

  include Spec::Examples::Controllers::ResourcesExamples
  include Spec::Examples::Controllers::RenderingExamples

  let(:user) { create(:user) }

  describe '#edit' do
    expect_behavior 'requires authentication'

    def perform_action
      get :edit, :directories => path
    end # method perform_action

    before(:each) { sign_in :user, user }

    wrap_context 'with an invalid path' do
      expect_behavior 'redirects to the last found directory dashboard'
    end # describe

    describe 'with a valid path to a blog' do
      include_context 'with a valid path to a feature'

      let(:resource) { create(:blog, :directory => directories.last) }

      expect_behavior 'renders template', :edit

      expect_behavior 'assigns directories'

      expect_behavior 'assigns the resource'
    end # describe

    describe 'with a valid path to a blog post' do
      include_context 'with a valid path to a feature'

      let(:blog)     { create(:blog, :directory => directories.last) }
      let(:resource) { create(:blog_post, :blog => blog, :content => build(:content)) }
      let(:path)     { segments.push(blog.slug, resource.slug).join('/') }

      expect_behavior 'renders template', :edit

      expect_behavior 'assigns directories'

      expect_behavior 'assigns the resource'
    end # describe

    wrap_context 'with a valid path to a directory' do
      let(:resource) { directories.last }

      expect_behavior 'renders template', :edit

      expect_behavior 'assigns directories'

      expect_behavior 'assigns the resource'
    end # describe

    describe 'with a valid path to a page' do
      include_context 'with a valid path to a feature'

      let(:resource) { create(:page, :directory => directories.last, :content => build(:content)) }

      expect_behavior 'renders template', :edit

      expect_behavior 'assigns directories'

      expect_behavior 'assigns the resource'
    end # describe
  end # describe

  describe '#update' do
    let(:resource_name) { :resource }
    let(:attributes)    { {} }

    expect_behavior 'requires authentication'

    def perform_action
      patch :update, :directories => path, resource_name => attributes
    end # method perform_action

    before(:each) { sign_in :user, user }

    wrap_context 'with an invalid path' do
      expect_behavior 'redirects to the last found directory dashboard'
    end # describe

    describe 'with a valid path to a blog' do
      include_context 'with a valid path to a feature'

      let(:resource_name) { :blog }
      let(:resource)      { create(:blog, :directory => directories.last) }

      describe 'with invalid params' do
        let(:attributes) { super().merge :title => nil }

        expect_behavior 'renders template', :edit

        expect_behavior 'assigns directories'

        expect_behavior 'assigns the resource'

        it 'does not update the resource' do
          expect { perform_action }.not_to change { resource.reload.title }
        end # it
      end # describe

      describe 'with valid params' do
        let(:attributes) { attributes_for(:blog) }

        it 'redirects to the blog' do
          perform_action

          expect(response.status).to be == 302
          expect(response).to redirect_to(blog_path(assigns :resource))

          expect(request.flash[:success]).not_to be_blank
        end # it

        it 'updates the resource' do
          expect { perform_action }.to change { resource.reload.title }.to(attributes[:title])
        end # it
      end # describe
    end # describe

    describe 'with a valid path to a blog post' do
      include_context 'with a valid path to a feature'

      let(:resource_name) { :post }
      let(:blog)          { create(:blog, :directory => directories.last) }
      let(:resource)      { create(:blog_post, :blog => blog, :content => build(:content)) }
      let(:path)          { segments.push(blog.slug, resource.slug).join('/') }

      describe 'with invalid params' do
        let(:attributes) { super().merge :title => nil }

        expect_behavior 'renders template', :edit

        expect_behavior 'assigns directories'

        expect_behavior 'assigns the resource'

        it 'does not update the resource' do
          expect { perform_action }.not_to change { resource.reload.title }
        end # it
      end # describe

      describe 'with valid params' do
        let(:attributes) { attributes_for(:blog_post) }

        it 'redirects to the post' do
          perform_action

          expect(response.status).to be == 302
          expect(response).to redirect_to(blog_post_path(assigns :resource))

          expect(request.flash[:success]).not_to be_blank
        end # it

        it 'updates the resource' do
          expect { perform_action }.to change { resource.reload.title }.to(attributes[:title])
        end # it
      end # describe
    end # describe

    wrap_context 'with a valid path to a directory' do
      let(:resource_name) { :directory }
      let(:resource)      { directories.last }

      describe 'with invalid params' do
        let(:attributes) { super().merge :title => nil }

        expect_behavior 'renders template', :edit

        expect_behavior 'assigns directories'

        expect_behavior 'assigns the resource'

        it 'does not update the resource' do
          expect { perform_action }.not_to change { resource.reload.title }
        end # it
      end # describe

      describe 'with valid params' do
        let(:attributes) { attributes_for(:directory) }

        it 'redirects to the directory' do
          perform_action

          expect(response.status).to be == 302
          expect(response).to redirect_to(dashboard_directory_path(assigns :resource))

          expect(request.flash[:success]).not_to be_blank
        end # it

        it 'updates the resource' do
          expect { perform_action }.to change { resource.reload.title }.to(attributes[:title])
        end # it
      end # describe
    end # describe

    describe 'with a valid path to a page' do
      include_context 'with a valid path to a feature'

      let(:resource_name) { :page }
      let(:resource)      { create(:page, :directory => directories.last, :content => build(:content)) }

      describe 'with invalid params' do
        let(:attributes) { super().merge :title => nil }

        expect_behavior 'renders template', :edit

        expect_behavior 'assigns directories'

        expect_behavior 'assigns the resource'

        it 'does not update the resource' do
          expect { perform_action }.not_to change { resource.reload.title }
        end # it
      end # describe

      describe 'with valid params' do
        let(:attributes) { attributes_for(:page) }

        it 'redirects to the page' do
          perform_action

          expect(response.status).to be == 302
          expect(response).to redirect_to(page_path(assigns :resource))

          expect(request.flash[:success]).not_to be_blank
        end # it

        it 'updates the resource' do
          expect { perform_action }.to change { resource.reload.title }.to(attributes[:title])
        end # it
      end # describe
    end # describe
  end # describe

  describe '#destroy' do
    expect_behavior 'requires authentication'

    def perform_action
      delete :destroy, :directories => path
    end # method perform_action

    before(:each) { sign_in :user, user }

    wrap_context 'with an invalid path' do
      expect_behavior 'redirects to the last found directory dashboard'
    end # describe

    describe 'with a valid path to a blog' do
      include_context 'with a valid path to a feature'

      let!(:resource) { create(:blog, :directory => directories.last) }

      it 'redirects to the parent directory' do
        parent_directory = directories.last

        perform_action

        expect(response.status).to be == 302
        expect(response).to redirect_to(dashboard_directory_path(parent_directory))

        expect(request.flash[:danger]).not_to be_blank
      end # it

      it 'destroys the resource' do
        expect { perform_action }.to change(Blog, :count).by(-1)
      end # it
    end # describe

    describe 'with a valid path to a blog post' do
      include_context 'with a valid path to a feature'

      let(:blog)      { create(:blog, :directory => directories.last) }
      let!(:resource) { create(:blog_post, :blog => blog, :content => build(:content)) }
      let(:path)      { segments.push(blog.slug, resource.slug).join('/') }

      it 'redirects to the blog' do
        perform_action

        expect(response.status).to be == 302
        expect(response).to redirect_to(blog_path(blog))

        expect(request.flash[:danger]).not_to be_blank
      end # it

      it 'destroys the resource' do
        expect { perform_action }.to change(blog.posts, :count).by(-1)
      end # it
    end # describe

    wrap_context 'with a valid path to a directory' do
      it 'redirects to the parent directory' do
        parent_directory = directories.last.parent

        perform_action

        expect(response.status).to be == 302
        expect(response).to redirect_to(dashboard_directory_path(parent_directory))

        expect(request.flash[:danger]).not_to be_blank
      end # it

      it 'destroys the resource' do
        expect { perform_action }.to change(Directory, :count).by(-1)
      end # it
    end # describe

    describe 'with a valid path to a page' do
      include_context 'with a valid path to a feature'

      let!(:resource) { create(:page, :directory => directories.last, :content => build(:content)) }

      it 'redirects to the parent directory' do
        parent_directory = directories.last

        perform_action

        expect(response.status).to be == 302
        expect(response).to redirect_to(dashboard_directory_path(parent_directory))

        expect(request.flash[:danger]).not_to be_blank
      end # it

      it 'destroys the resource' do
        expect { perform_action }.to change(Page, :count).by(-1)
      end # it
    end # describe
  end # describe

  describe '#publish' do
    expect_behavior 'requires authentication'

    def perform_action
      put :publish, :directories => path
    end # method perform_action

    before(:each) { sign_in :user, user }

    wrap_context 'with an invalid path' do
      expect_behavior 'redirects to the last found directory dashboard'
    end # describe

    describe 'with a valid path to a blog' do
      include_context 'with a valid path to a feature'

      let!(:resource) { create(:blog, :directory => directories.last) }

      it 'redirects to the resource' do
        perform_action

        expect(response.status).to be == 302
        expect(response).to redirect_to(blog_path(resource))

        expect(request.flash[:warning]).not_to be_blank
      end # it
    end # describe

    describe 'with a valid path to a blog post' do
      include_context 'with a valid path to a feature'

      let(:blog)      { create(:blog, :directory => directories.last) }
      let!(:resource) { create(:blog_post, :blog => blog, :content => build(:content)) }
      let(:path)      { segments.push(blog.slug, resource.slug).join('/') }

      it 'redirects to the post' do
        perform_action

        expect(response.status).to be == 302
        expect(response).to redirect_to(blog_post_path(resource))

        expect(request.flash[:success]).not_to be_blank
      end # it

      it 'publishes the post' do
        expect { perform_action }.to change { resource.reload.published_at }.to be_a ActiveSupport::TimeWithZone
      end # it
    end # describe

    wrap_context 'with a valid path to a directory' do
      it 'redirects to the directory' do
        perform_action

        expect(response.status).to be == 302
        expect(response).to redirect_to(dashboard_directory_path(directories.last))

        expect(request.flash[:warning]).not_to be_blank
      end # it
    end # describe

    describe 'with a valid path to a page' do
      include_context 'with a valid path to a feature'

      let!(:resource) { create(:page, :directory => directories.last, :content => build(:content)) }

      it 'redirects to the page' do
        perform_action

        expect(response.status).to be == 302
        expect(response).to redirect_to(page_path(resource))

        expect(request.flash[:success]).not_to be_blank
      end # it

      it 'publishes the page' do
        expect { perform_action }.to change { resource.reload.published_at }.to be_a ActiveSupport::TimeWithZone
      end # it
    end # describe
  end # describe

  describe '#unpublish' do
    expect_behavior 'requires authentication'

    def perform_action
      put :unpublish, :directories => path
    end # method perform_action

    before(:each) { sign_in :user, user }

    wrap_context 'with an invalid path' do
      expect_behavior 'redirects to the last found directory dashboard'
    end # describe

    describe 'with a valid path to a blog' do
      include_context 'with a valid path to a feature'

      let!(:resource) { create(:blog, :directory => directories.last) }

      it 'redirects to the resource' do
        perform_action

        expect(response.status).to be == 302
        expect(response).to redirect_to(blog_path(resource))

        expect(request.flash[:warning]).not_to be_blank
      end # it
    end # describe

    describe 'with a valid path to a blog post' do
      include_context 'with a valid path to a feature'

      let(:blog)      { create(:blog, :directory => directories.last) }
      let!(:resource) { create(:blog_post, :blog => blog, :content => build(:content), :published_at => 1.day.ago) }
      let(:path)      { segments.push(blog.slug, resource.slug).join('/') }

      it 'redirects to the post' do
        perform_action

        expect(response.status).to be == 302
        expect(response).to redirect_to(blog_post_path(resource))

        expect(request.flash[:warning]).not_to be_blank
      end # it

      it 'unpublishes the post' do
        expect { perform_action }.to change { resource.reload.published_at }.to nil
      end # it

      it 'clears the published order cache' do
        expect { perform_action }.to change { resource.reload.published_order }.to nil
      end # it
    end # describe

    wrap_context 'with a valid path to a directory' do
      it 'redirects to the directory' do
        perform_action

        expect(response.status).to be == 302
        expect(response).to redirect_to(dashboard_directory_path(directories.last))

        expect(request.flash[:warning]).not_to be_blank
      end # it
    end # describe

    describe 'with a valid path to a page' do
      include_context 'with a valid path to a feature'

      let!(:resource) { create(:page, :directory => directories.last, :content => build(:content), :published_at => 1.day.ago) }

      it 'redirects to the page' do
        perform_action

        expect(response.status).to be == 302
        expect(response).to redirect_to(page_path(resource))

        expect(request.flash[:warning]).not_to be_blank
      end # it

      it 'unpublishes the page' do
        expect { perform_action }.to change { resource.reload.published_at }.to nil
      end # it
    end # describe
  end # describe
end # describe
