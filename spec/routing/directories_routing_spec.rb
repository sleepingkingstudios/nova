# spec/routing/directories_routing_spec.rb

require 'rails_helper'

RSpec.describe 'routing for directories', :type => :routing do
  describe 'GET /path/to/directory' do
    let(:path) { 'weapons/bows/arbalest' }

    it 'routes to DirectoriesController#show' do
      expect(:get => "/#{path}").to route_to({
        :controller  => 'directories',
        :action      => 'show',
        :directories => path
      })
    end # it
  end # describe

  describe 'GET /admin/path/to/directory' do
    let(:path) { 'admin/weapons/bows/arbalest' }

    it 'does not route' do
      expect(:get => "/#{path}").not_to be_routable
    end # it
  end # describe
end # describe