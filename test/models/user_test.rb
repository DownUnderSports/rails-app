require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def valid_attributes
    {
      category: "supporter",
      first_names: "John Jacob",
      last_names: "Jingleheimer-Smith",
      data: {}
    }
  end

  def assert_single_use_digest(user, mthd = :password_reset)
    key_was = key = ""
    digest_was = nil

    10.times do
      key = user.__send__ mthd

      refute_nil user.single_use_digest
      assert user.authenticate_single_use(key)

      refute_equal key_was, key
      refute_equal digest_was, user.single_use_digest
      refute user.authenticate_single_use(key_was)

      key_was    = key
      digest_was = user.single_use_digest
    end

    [ key, user.single_use_digest ]
  end

  test 'valid person' do
    user = User.new(valid_attributes)
    assert user.valid?

    # optional columns
    [
      :title,
      :middle_names,
      :suffix,
      :email,
      :password,
      :single_use,
      :single_use_expires_at,
    ].each do |attr|
      assert user.respond_to?(attr)
      assert user.respond_to?(:"#{attr}=")

      user.__send__ :"#{attr}=", "#{rand}.#{Time.zone.now}"

      if attr == :password
        refute user.valid?
        user.email = "#{rand}@email.com"
      end

      assert user.valid?

      user.__send__ :"#{attr}=", nil

      assert user.valid?

      if attr == :password
        user.email = nil
        assert user.valid?
      end
    end
  end

  test 'invalid user with invalid password_confirmation' do
    user = User.new(valid_attributes.merge(password: rand.to_s, password_confirmation: rand.to_s))
    refute user.valid?, 'user is invalid when password_confirmation does not match'
    assert_not_nil user.errors[:password_confirmation]
    assert_equal [ "doesn't match Password" ], user.errors[:password_confirmation]
  end

  test '#password_reset generates a new single_use_digest and returns the associated key' do
    user = User.new valid_attributes

    assert user.save

    assert_nil user.single_use_digest

    key, digest = assert_single_use_digest user

    assert user.authenticate_single_use(key)
    assert_equal digest, user.single_use_digest

    user.reload

    refute user.authenticate_single_use(key)
    refute_equal digest, user.single_use_digest
  end

  test '#password_reset! generates a new single_use_digest saves the record, and returns the associated key' do
    user = User.new valid_attributes

    assert user.save

    assert_nil user.single_use_digest

    key, digest = assert_single_use_digest user, :password_reset!

    assert user.authenticate_single_use(key)
    assert_equal digest, user.single_use_digest

    user.reload

    assert user.authenticate_single_use(key)
    assert_equal digest, user.single_use_digest
  end
end
