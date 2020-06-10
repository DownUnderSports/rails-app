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

  def attributes_without(*keys)
    valid_attributes.except(*keys)
  end

  def assert_database_constraint(user, attribute, klass)
    err = assert_raises(klass) do
      user.save(validate: false)
    end

    err
  end

  def assert_database_not_null_constraint(attribute)
    user = User.new(attributes_without attribute)

    err = assert_database_constraint user, attribute, ActiveRecord::NotNullViolation

    assert_match \
      "null value in column \"#{attribute}\" violates not-null constraint",
      err.message
  end

  def assert_database_unique_constraint(attribute)
    duplicate = users(:athlete).__send__(attribute)
    user      = User.new(valid_attributes.merge(attribute => duplicate))
    err       = assert_database_constraint user, attribute, ActiveRecord::RecordNotUnique

    assert_match \
      "duplicate key value violates unique constraint",
      err.message

    assert_match \
      "DETAIL:  Key (#{attribute})=(#{duplicate}) already exists.",
      err.message
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

  test 'valid user' do
    user = User.new(valid_attributes)
    assert user.valid?

    # optional columns
    [
      :title,
      :middle_names,
      :suffix,
      :email,
      :password,
      :single_use_digest,
      :single_use_expires_at,
    ].each do |attr|
      assert user.respond_to?(attr)
      assert user.respond_to?(:"#{attr}=")

      user.__send__ :"#{attr}=", "#{rand}.#{Time.zone.now}"

      assert user.valid?

      user.__send__ :"#{attr}=", nil

      assert user.valid?
    end
  end

  test 'invalid user without category' do
    user = User.new(attributes_without :category)
    refute user.valid?, 'user is valid without category'
    assert_not_nil user.errors[:category]
    assert_equal [ "can't be blank" ], user.errors[:category]

    assert_database_not_null_constraint :category
  end

  test 'invalid user with invalid category' do
    user = User.new(valid_attributes.merge(category: "asdf"))
    refute user.valid?, 'user is valid with invalid category'
    assert_not_nil user.errors[:category]
    assert_equal [ "is not recognized" ], user.errors[:category]
  end

  test 'invalid user without first name(s)' do
    user = User.new(attributes_without :first_names)
    refute user.valid?, 'user is valid without first name(s)'
    assert_not_nil user.errors[:first_names]
    assert_equal [ "can't be blank" ], user.errors[:first_names]

    assert_database_not_null_constraint :first_names
  end

  test 'invalid user without last name(s)' do
    user = User.new(attributes_without :last_names)
    refute user.valid?, 'user is valid without last name(s)'
    assert_not_nil user.errors[:last_names]
    assert_equal [ "can't be blank" ], user.errors[:last_names]

    assert_database_not_null_constraint :last_names
  end

  test 'invalid user with reused email' do
    user = User.new(valid_attributes.merge(email: users(:athlete).email))
    refute user.valid?, 'user is invalid with an email already in use'
    assert_not_nil user.errors[:email]
    assert_equal [ "has already been taken" ], user.errors[:email]

    assert_database_unique_constraint :email
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
