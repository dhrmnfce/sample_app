require 'test_helper'

class MicropostsControllerTest < ActionController::TestCase
  
  def setup
    @micropost = microposts(:orange)
    @request.env['HTTP_REFERER'] = 'http://test.host/users/382580536' || root_url # Stores location of users(:droid) profile for redirect when admin destroys a droid post
  end
  
  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post :create, micropost: { content: "Lorem Ipsum" }
    end
    assert_redirected_to login_url
  end
  
  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete :destroy, id: @micropost
    end
    assert_redirected_to login_url
  end
  
  test "should redirect destroy for wrong user, if not logged in as admin" do
    log_in_as(users(:puter))
    micropost = microposts(:ants)
    assert_no_difference 'Micropost.count' do
      delete :destroy, id: micropost
    end
    assert_redirected_to root_url
  end
  
  test "should allow destroy for wrong user if logged in as admin" do
    log_in_as(users(:dylan))
    micropost = microposts(:ants) # Droid post
    assert_difference 'Micropost.count', -1 do
      delete :destroy, id: micropost
    end
    assert_redirected_to @request.env['HTTP_REFERER']
  end
  
end
