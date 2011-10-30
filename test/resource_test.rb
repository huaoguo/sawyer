require File.expand_path("../helper", __FILE__)

module Sawyer
  class ResourceTest < TestCase
    def test_accessible_keys
      res = Resource.new :agent, :a => 1,
        :_links => {:self => {:_href => '/'}}

      assert_equal 1, res.a
      assert res.rels[:self]
      assert_equal :agent, res.agent
      assert_equal 1, res.fields.size
      assert res.fields.include?(:a)
    end

    def test_clashing_keys
      res = Resource.new :agent, :agent => 1, :rels => 2, :fields => 3,
        :_links => {:self => {:_href => '/'}}

      assert_equal 1, res.agent
      assert_equal 2, res.rels
      assert_equal 3, res.fields

      assert res._rels[:self]
      assert_equal :agent, res._agent
      assert_equal 3, res._fields.size
      [:agent, :rels, :fields].each do |f|
        assert res._fields.include?(f)
      end
    end

    def test_nested_object
      res = Resource.new :agent,
        :user   => {:id => 1, :_links => {:self => {:_href => '/users/1'}}},
        :_links => {:self => {:_href => '/'}}

      assert_equal '/', res.rels[:self].href
      assert_kind_of Resource, res.user
      assert_equal 1, res.user.id
      assert_equal '/users/1', res.user.rels[:self].href
    end

    def test_nested_collection
      res = Resource.new :agent,
        :users  => [{:id => 1, :_links => {:self => {:_href => '/users/1'}}}],
        :_links => {:self => {:_href => '/'}}

      assert_equal '/', res.rels[:self].href
      assert_kind_of Array, res.users

      assert user = res.users.first
      assert_kind_of Resource, user
      assert_equal 1, user.id
      assert_equal '/users/1', user.rels[:self].href
    end

    def test_attribute_predicates
      res = Resource.new :agent, :a => 1, :b => true, :c => nil, :d => false

      assert  res.a?
      assert  res.b?
      assert !res.c?
      assert !res.d?
    end

    def test_attribute_setter
      res = Resource.new :agent, :a => 1
      assert_equal 1, res.a
      assert !res.key?(:b)

      res.b = 2
      assert_equal 2, res.b
      assert res.key?(:b)
    end

    def test_dynamic_attribute_methods_from_getter
      res = Resource.new :agent, :a => 1
      assert  res.key?(:a)
      assert !res.respond_to?(:a)
      assert !res.respond_to?(:a=)

      assert_equal 1, res.a
      assert res.respond_to?(:a)
      assert res.respond_to?(:a=)
    end

    def test_dynamic_attribute_methods_from_setter
      res = Resource.new :agent, :a => 1
      assert !res.key?(:b)
      assert !res.respond_to?(:b)
      assert !res.respond_to?(:b=)

      res.b = 1
      assert res.key?(:b)
      assert res.respond_to?(:b)
      assert res.respond_to?(:b=)
    end
  end
end