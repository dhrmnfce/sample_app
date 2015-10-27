require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:dylan)
    @non_admin = users(:droid)
  end

  test "micropost interface as non admin" do
    log_in_as(@non_admin)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # Invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, micropost: { content: "" }
    end
    assert_select 'div#error_explanation'
    # Valid submission
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, micropost: { content: content, picture: picture }
    end
    assert assigns(:micropost).picture?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # Delete a post.
    assert_select 'a', text: 'delete'
    first_micropost = @non_admin.microposts.paginate(page: 1, per_page: 25).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # Visit a different user.
    get user_path(users(:puter))
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "micropost interface as admin" do
    log_in_as(@admin)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # Invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, micropost: { content: "" }
    end
    assert_select 'div#error_explanation'
    # Valid submission
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, micropost: { content: content, picture: picture }
    end
    assert assigns(:micropost).picture?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # Delete a post.
    assert_select 'a', text: 'delete'
    first_micropost = @admin.microposts.paginate(page: 1, per_page: 25).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # Visit a different user.
    get user_path(users(:puter))
    assert_select 'a', text: 'delete', count: 15 # user profiles display 15 posts, you should see 15 'delete' buttons 
  end
  
  test "micropost sidebar count" do
    log_in_as(@admin)
    get root_path
    assert_match "#{@admin.microposts.count} posts", response.body
    # User with zero microposts
    other_user = users(:no_posts_user)
    log_in_as(other_user)
    get root_path
    assert_match "0 posts", response.body
    other_user.microposts.create!(content: "A post")
    get root_path
    assert_match "#{other_user.microposts.count} post", response.body
  end
  
end
