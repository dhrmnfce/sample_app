require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  def setup
    @user = users(:dylan)
    @user2 = users(:puter)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should redirect edit when not logged in" do
    get :edit, id: @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect update when not logged in" do
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should should redirect edit when logged in as wrong user" do
    log_in_as(@user2)
    get :edit, id: @user
    assert flash.empty?
    assert_redirected_to root_url
  end
  
  test "should should redirect update when logged in as wrong user" do
    log_in_as(@user2)
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert flash.empty?
    assert_redirected_to root_url
  end
  
  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end
  
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as non-admin" do
    log_in_as(@user2)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end
  
  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@user2)
    assert_not @user2.admin?
    patch :update, id: @user2, user: { password: 'password', password_confirmation: 'password', admin: true }
    assert_not @user2.reload.admin?
  end
  
  test "should redirect following when not logged in" do
    get :following, id: @user
    assert_redirected_to login_url
  end
  
  test "should redirect show followers when not logged in" do
    get :followers, id: @user
    assert_redirected_to login_url
  end

end
