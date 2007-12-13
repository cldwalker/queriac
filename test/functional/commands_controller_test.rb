require File.dirname(__FILE__) + '/../test_helper'
require 'commands_controller'

# Re-raise errors caught by the controller.
class CommandsController; def rescue_action(e) raise e end; end

class CommandsControllerTest < Test::Unit::TestCase
  fixtures :commands

  def setup
    @controller = CommandsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:commands)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_command
    old_count = Command.count
    post :create, :command => { }
    assert_equal old_count+1, Command.count
    
    assert_redirected_to command_path(assigns(:command))
  end

  def test_should_show_command
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_command
    put :update, :id => 1, :command => { }
    assert_redirected_to command_path(assigns(:command))
  end
  
  def test_should_destroy_command
    old_count = Command.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Command.count
    
    assert_redirected_to commands_path
  end
end
