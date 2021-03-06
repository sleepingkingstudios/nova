# spec/support/examples/controllers/resources_examples.rb

require 'support/contexts/controllers/resources_contexts'
require 'support/examples/controllers/rendering_examples'

module Spec
  module Examples
    module Controllers
      module ResourcesExamples
        extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

        include RoutesHelper

        include Spec::Contexts::Controllers::ResourcesContexts

        include Spec::Examples::Controllers::RenderingExamples

        def default_url_options(options = {})
          defined?(super) ? super(options) : options
        end # method default_url_options

        shared_examples 'assigns directories' do
          it 'assigns the directories to @directories' do
            perform_action

            expect(assigns :directories).to be == directories
          end # it
        end # shared_examples

        shared_examples 'assigns new content' do |content_type = Content|
          it 'assigns the content to @resource.content' do
            perform_action

            expect(assigns(:resource).content).to be_a content_type
          end # it
        end # shared_examples

        shared_examples 'assigns new directory' do
          it 'assigns the directory to @directory' do
            perform_action

            expect(assigns :directory).to be_a Directory
            expect(assigns(:directory).parent).to be == directories.last
          end # it
        end # shared_examples

        shared_examples 'assigns new resource' do |resource, assigns_directory: false|
          resource_type = case resource
          when String
            resource.classify.constantize
          when Class
            resource
          else
            resource.class
          end # case

          it 'assigns the resource to @resource' do
            perform_action

            expect(assigns :resource).to be_a resource_type
            if assigns_directory
              expect(assigns(:resource).directory).to be == directories.last
            end # if
          end # it
        end # shared_examples

        shared_examples 'assigns the resource' do
          it 'assigns the resource to @resource' do
            perform_action

            expect(assigns :resource).to be == resource
          end # it
        end # shared_examples

        shared_examples 'redirects to the last found directory' do
          it 'redirects to the last found directory' do
            perform_action

            expect(response.status).to be == 302
            expect(response).to redirect_to directory_path(assigns(:directories).last)

            expect(request.flash[:warning]).not_to be_blank
          end # it
        end # shared_examples

        shared_examples 'redirects to the last found directory dashboard' do
          it 'redirects to the last found directory dashboard' do
            perform_action

            expect(response.status).to be == 302
            expect(response).to redirect_to dashboard_directory_path(assigns(:directories).last)

            expect(request.flash[:warning]).not_to be_blank
          end # it
        end # shared_examples

        shared_examples 'requires authentication' do
          before(:each) { sign_out :user }

          wrap_context 'with an invalid path' do
            it 'redirects to the last found directory' do
              perform_action

              expect(response.status).to be == 302
              expect(response).to redirect_to directory_path(assigns(:directories).last)

              expect(request.flash[:warning]).not_to be_blank
            end # it
          end # describe

          describe 'with a valid path' do
            include_context 'with a valid path to a directory'

            it 'redirects to the last found directory' do
              perform_action

              expect(response.status).to be == 302
              expect(response).to redirect_to directory_path(assigns(:directories).last)

              expect(request.flash[:warning]).not_to be_blank
            end # it
          end # describe
        end # shared_examples

        shared_examples 'requires authentication for root directory' do
          before(:each) { sign_out :user }

          wrap_context 'with an empty path' do
            it 'redirects to root' do
              perform_action

              expect(response.status).to be == 302
              expect(response).to redirect_to root_path

              expect(request.flash[:warning]).not_to be_blank
            end # it
          end # describe
        end # shared_examples
      end # module
    end # module
  end # module
end # module
