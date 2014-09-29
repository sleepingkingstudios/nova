# spec/routing/directories_routing_spec.rb

require 'rails_helper'

RSpec.describe 'routing for directories', :type => :routing do
  let(:controller) { 'directories' }

  describe 'GET /' do
    let(:path) { '/' }

    it 'routes to DirectoriesController#show' do
      expect(:get => "/#{path}").to route_to({
        :controller  => controller,
        :action      => 'show'
      }) # end hash
    end # it
  end # describe

  describe 'GET /path/to/directory' do
    let(:path) { 'weapons/bows/arbalests' }

    it 'routes to DirectoriesController#show' do
      expect(:get => "/#{path}").to route_to({
        :controller  => controller,
        :action      => 'show',
        :directories => path
      }) # end hash
    end # it
  end # describe

  describe 'GET /admin/path/to/directory' do
    let(:path) { 'admin/weapons/bows/arbalests' }

    it 'does not route' do
      expect(:get => "/#{path}").not_to be_routable
    end # it
  end # describe
end # describe
