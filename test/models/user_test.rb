require File.dirname(__FILE__) + '/../test_helper'
class UserTest < ActiveSupport::TestCase
  test 'should not create user' do
    user = User.create
    assert user.errors
  end

  test 'should create user' do
    count = User.count
    user = User.create(login: 'cess', email: 'nairobi@gmail.com')
    assert user.errors
    assert_equal User.count, count + 1
  end

  test 'should require login' do
    user = User.create(login: nil)
    assert_not_nil user.errors
    assert !user.save
    assert_includes(
      user.errors.full_messages.to_sentence, "Login can't be blank"
    )
  end

  test 'should require email' do
    user = User.create(email: nil)
    assert_not_nil user.errors
    assert !user.save
    assert_includes(
      user.errors.full_messages.to_sentence, "Email can't be blank"
    )
  end

  test 'should confirm if user can edit and delete map' do
    user = users(:quentin)
    map = maps(:saugus)
    assert user.owns?(map)
    assert user.can_delete?(map)
    assert user.can_edit?(map)
    assert_equal map.updated_at, user.last_action
  end

  test 'warpables through maps relationship' do
    user = users(:quentin)
    map_images = user.maps.map(&:warpables)

    map_images.flatten.each do |image|
      user.warpables.each do |warpable|
        assert_equal image.class, warpable.class
      end
    end

    assert_equal map_images.flatten, user.warpables
  end

  test 'should ban and unban user' do
    user = users(:quentin)
    assert_equal User::Status::NORMAL, user.status
    assert_nil user.status_updated_at

    user.ban
    assert_equal User::Status::BANNED, user.status
    assert_not_nil user.status_updated_at
    old_time = user.status_updated_at

    user.unban
    assert_equal User::Status::NORMAL, user.status
    assert user.status_updated_at.to_f >= old_time.to_f
  end

  test 'should confirm if user can moderate' do
    admin = users(:admin)
    assert admin.can_moderate?

    user = users(:quentin)
    assert_not user.can_moderate?
  end

  # def test_should_authenticate_user
  #   assert_equal users(:quentin), User.authenticate('quentin', 'monkey')
  # end
  #
  #  def test_should_set_remember_token
  #    users(:quentin).remember_me
  #    assert_not_nil users(:quentin).remember_token
  #    assert_not_nil users(:quentin).remember_token_expires_at
  #  end
  #
  #  def test_should_unset_remember_token
  #    users(:quentin).remember_me
  #    assert_not_nil users(:quentin).remember_token
  #    users(:quentin).forget_me
  #    assert_nil users(:quentin).remember_token
  #  end
  #
  #  def test_should_remember_me_for_one_week
  #    before = 1.week.from_now.utc
  #    users(:quentin).remember_me_for 1.week
  #    after = 1.week.from_now.utc
  #    assert_not_nil users(:quentin).remember_token
  #    assert_not_nil users(:quentin).remember_token_expires_at
  #    assert users(:quentin).remember_token_expires_at.between?(before, after)
  #  end
  #
  #  def test_should_remember_me_until_one_week
  #    time = 1.week.from_now.utc
  #    users(:quentin).remember_me_until time
  #    assert_not_nil users(:quentin).remember_token
  #    assert_not_nil users(:quentin).remember_token_expires_at
  #    assert_equal users(:quentin).remember_token_expires_at, time
  #  end
  #
  #  def test_should_remember_me_default_two_weeks
  #    before = 2.weeks.from_now.utc
  #    users(:quentin).remember_me
  #    after = 2.weeks.from_now.utc
  #    assert_not_nil users(:quentin).remember_token
  #    assert_not_nil users(:quentin).remember_token_expires_at
  #    assert users(:quentin).remember_token_expires_at.between?(before, after)
  #  end
end
