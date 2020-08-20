require 'test_helper'

class PersonAttributesTest < ActiveSupport::TestCase
  def valid_attributes
    {
      category: "supporter",
      first_names: "John Jacob",
      last_names: "Jingleheimer-Smith",
      data: {}
    }
  end

  def assert_database_not_null_constraint(attribute, **opts)
    super Person, attribute, **opts
  end

  def assert_database_unique_constraint(*attributes)
    values = {}
    Array(attributes).flatten.each do |attr|
      values[attr.to_sym] = person_fixtures(:athlete).__send__(attr)
    end
    super Person, **values
  end

  test 'valid person' do
    person = Person.new(valid_attributes)
    assert person.valid?

    # optional columns
    [
      :title,
      :middle_names,
      :suffix,
      :email,
      :password_digest,
      :single_use_digest,
      :single_use_expires_at,
    ].each do |attr|
      assert person.respond_to?(attr)
      assert person.respond_to?(:"#{attr}=")

      person.__send__ :"#{attr}=", "#{rand}.#{Time.zone.now}"
      if attr == :password_digest
        refute person.valid?
        person.email = "#{rand}@email.com"
      end

      assert person.valid?

      person.__send__ :"#{attr}=", nil

      assert person.valid?

      if attr == :password_digest
        person.email = nil
        assert person.valid?
      end
    end
  end

  test 'invalid person without category' do
    person = Person.new(attributes_without :category)
    refute person.valid?, 'person is valid without category'
    assert_not_nil person.errors[:category]
    assert_equal [ "can't be blank" ], person.errors[:category]

    assert_database_not_null_constraint :category
  end

  test 'invalid person with invalid category' do
    person = Person.new(valid_attributes.merge(category: "asdf"))
    refute person.valid?, 'person is valid with invalid category'
    assert_not_nil person.errors[:category]
    assert_equal [ "is not recognized" ], person.errors[:category]
  end

  test 'invalid person without first name(s)' do
    person = Person.new(attributes_without :first_names)
    refute person.valid?, 'person is valid without first name(s)'
    assert_not_nil person.errors[:first_names]
    assert_equal [ "can't be blank" ], person.errors[:first_names]

    assert_database_not_null_constraint :first_names
  end

  test 'invalid person without last name(s)' do
    person = Person.new(attributes_without :last_names)
    refute person.valid?, 'person is valid without last name(s)'
    assert_not_nil person.errors[:last_names]
    assert_equal [ "can't be blank" ], person.errors[:last_names]

    assert_database_not_null_constraint :last_names
  end

  test 'invalid person with reused email' do
    person = Person.new(valid_attributes.merge(email: person_fixtures(:athlete).email))
    refute person.valid?, 'person is valid with an email already in use'
    assert_not_nil person.errors[:email]
    assert_equal [ "has already been taken" ], person.errors[:email]

    assert_database_unique_constraint :email
  end

  test 'valid person with blank email and blank password_digest' do
    person = Person.new(valid_attributes.merge(email: nil))
    assert person.valid?, 'person with blank password is invalid with a blank email'
  end

  test 'invalid person with blank email and existing password_digest' do
    person = Person.new(valid_attributes.merge(password_digest: RbNaCl::Random.random_bytes(64).unpack_binary))
    refute person.valid?, 'person with password is valid with a blank email'
    assert_not_nil person.errors[:email]
    assert_equal [ "required for login" ], person.errors[:email]
  end

  test 'data uses a hash with indifferent access' do
    assert_has_indifferent_hash Person.new, :data
  end
end
