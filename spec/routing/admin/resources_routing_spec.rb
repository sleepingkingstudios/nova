# spec/routing/admin/resources_routing_spec.rb

require 'rails_helper'

RSpec.describe 'admin routing for resources', :type => :routing do
  let(:resources_controller) { 'admin/resources' }

  describe 'GET /path/to/directory/edit' do
    let(:path) { 'weapons/bows/arbalests/edit' }

    it 'routes to Admin::ResourcesController#edit' do
      expect(:get => "/#{path}").to route_to({
        :controller  => resources_controller,
        :action      => 'edit',
        :directories => 'weapons/bows/arbalests'
      }) # end hash
    end # it
  end # describe

  describe 'PUT /path/to/directory/publish' do
    let(:path) { 'weapons/bows/arbalests/publish' }

    it 'routes to Admin::ResourcesController#update' do
      expect(:put => "/#{path}").to route_to({
        :controller  => resources_controller,
        :action      => 'publish',
        :directories => 'weapons/bows/arbalests'
      }) # end hash
    end # it
  end # describe

  describe 'PUT /path/to/directory/unpublish' do
    let(:path) { 'weapons/bows/arbalests/unpublish' }

    it 'routes to Admin::ResourcesController#update' do
      expect(:put => "/#{path}").to route_to({
        :controller  => resources_controller,
        :action      => 'unpublish',
        :directories => 'weapons/bows/arbalests'
      }) # end hash
    end # it
  end # describe

  describe 'PATCH /path/to/directory' do
    let(:path) { 'weapons/bows/arbalests' }

    it 'routes to Admin::ResourcesController#update' do
      expect(:patch => "/#{path}").to route_to({
        :controller  => resources_controller,
        :action      => 'update',
        :directories => 'weapons/bows/arbalests'
      }) # end hash
    end # it
  end # describe

  describe 'PUT /path/to/directory' do
    let(:path) { 'weapons/bows/arbalests' }

    it 'routes to Admin::ResourcesController#update' do
      expect(:put => "/#{path}").to route_to({
        :controller  => resources_controller,
        :action      => 'update',
        :directories => 'weapons/bows/arbalests'
      }) # end hash
    end # it
  end # describe

  describe 'DELETE /path/to/directory' do
    let(:path) { 'weapons/bows/arbalests' }

    it 'routes to Admin::ResourcesController#destroy' do
      expect(:delete => "/#{path}").to route_to({
        :controller  => resources_controller,
        :action      => 'destroy',
        :directories => 'weapons/bows/arbalests'
      }) # end hash
    end # it
  end # describe
end # describe
