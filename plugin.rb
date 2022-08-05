# frozen_string_literal: true

# name: custom-fields
# about: Discourse plugin showing how to add custom fields to Discourse topics
# version: 1.0
# authors: Joe Stanton
# contact email: intunedeals@gmail.com
# url: https://github.com/JStantonWordPress/CustomFields

enabled_site_setting :topic_custom_field_enabled
register_asset 'stylesheets/common.scss'

##
# type:        introduction
# title:       Add a custom field to a topic
# description: To get started, load the [discourse-topic-custom-fields](https://github.com/pavilionedu/discourse-topic-custom-fields)
#              plugin in your local development environment. Once you've got it
#              working, follow the steps below and in the client "initializer"
#              to understand how it works. For more about the context behind
#              each step, follow the links in the 'references' section.
##

after_initialize do
  Price = "Price"
  URL = "URL"
  Store = "Store"
  FIELD_TYPE = "string"

  ##
  # type:        step
  # number:      1
  # title:       Register the field
  # description: Where we tell discourse what kind of field we're adding. You
  #              can register a string, integer, boolean or json field.
  # references:  lib/plugins/instance.rb,
  #              app/models/concerns/has_custom_fields.rb
  ##
  register_topic_custom_field_type(Price, FIELD_TYPE.to_sym)
  register_topic_custom_field_type(URL, FIELD_TYPE.to_sym)
  register_topic_custom_field_type(Store, FIELD_TYPE.to_sym)
  ##
  # type:        step
  # number:      2
  # title:       Add getter and setter methods
  # description: Adding getter and setter methods is optional, but advisable.
  #              It means you can handle data validation or normalisation, and
  #              it lets you easily change where you're storing the data.
  ##

  ##
  # type:        step
  # number:      2.1
  # title:       Getter method
  # references:  lib/plugins/instance.rb,
  #              app/models/topic.rb,
  #              app/models/concerns/has_custom_fields.rb
  ##
  add_to_class(:topic, Price.to_sym) do
    if !custom_fields[Price].nil?
      custom_fields[Price]
    else
      nil
    end
  end

  add_to_class(:topic, URL.to_sym) do
    if !custom_fields[URL].nil?
      custom_fields[URL]
    else
      nil
    end
  end

    add_to_class(:topic, Store.to_sym) do
      if !custom_fields[Store].nil?
        custom_fields[Store]
      else
        nil
      end
    end
  ##
  # type:        step
  # number:      2.2
  # title:       Setter method
  # references:  lib/plugins/instance.rb,
  #              app/models/topic.rb,
  #              app/models/concerns/has_custom_fields.rb
  ##
  add_to_class(:topic, "#{Price}=") do |value|
    custom_fields[Price] = value
  end

  add_to_class(:topic, "#{URL}=") do |value|
    custom_fields[URL] = value
  end

    add_to_class(:topic, "#{Store}=") do |value|
      custom_fields[Store] = value
    end
  ##
  # type:        step
  # number:      3
  # title:       Update the field when the topic is created or updated
  # description: Topic creation is contingent on post creation. This means that
  #              many of the topic update classes are associated with the post
  #              update classes.
  ##

  ##
  # type:        step
  # number:      3.1
  # title:       Update on topic creation
  # description: Here we're using an event callback to update the field after
  #              the first post in the topic, and the topic itself, is created.
  # references:  lib/plugins/instance.rb,
  #              lib/post_creator.rb
  ##
  on(:topic_created) do |topic, opts, user|
    topic.send("#{Price}=".to_sym, opts[Price.to_sym])
    topic.save!
  end

    on(:topic_created) do |topic, opts, user|
      topic.send("#{URL}=".to_sym, opts[URL.to_sym])
      topic.save!
    end

    on(:topic_created) do |topic, opts, user|
      topic.send("#{Store}=".to_sym, opts[Store.to_sym])
      topic.save!
    end

  ##
  # type:        step
  # number:      3.2
  # title:       Update on topic edit
  # description: Update the field when it's updated in the composer when
  #              editing the first post in the topic, or in the topic title
  #              edit view.
  # references:  lib/plugins/instance.rb,
  #              lib/post_revisor.rb
  ##
  PostRevisor.track_topic_field(Price.to_sym) do |tc, value|
    tc.record_change(Price, tc.topic.send(Price), value)
    tc.topic.send("#{Price}=".to_sym, value.present? ? value : nil)
  end

  PostRevisor.track_topic_field(URL.to_sym) do |tc, value|
    tc.record_change(URL, tc.topic.send(URL), value)
    tc.topic.send("#{URL}=".to_sym, value.present? ? value : nil)
  end

    PostRevisor.track_topic_field(Store.to_sym) do |tc, value|
      tc.record_change(Store, tc.topic.send(Store), value)
      tc.topic.send("#{Store}=".to_sym, value.present? ? value : nil)
    end
  ##
  # type:        step
  # number:      4
  # title:       Serialize the field
  # description: Send our field to the client, along with the other topic
  #              fields.
  ##

  ##
  # type:        step
  # number:      4.1
  # title:       Serialize to the topic
  # description: Send your field to the topic.
  # references:  lib/plugins/instance.rb,
  #              app/serializers/topic_view_serializer.rb
  ##
  add_to_serializer(:topic_view, Price.to_sym) do
    object.topic.send(Price)
  end

  add_to_serializer(:topic_view, URL.to_sym) do
    object.topic.send(URL)
  end

    add_to_serializer(:topic_view, Store.to_sym) do
      object.topic.send(Store)
    end
  ##
  # type:        step
  # number:      4.2
  # title:       Preload the field
  # description: Discourse preloads custom fields on listable models (i.e.
  #              categories or topics) before serializing them. This is to
  #              avoid running a potentially large number of SQL queries
  #              ("N+1 Queries") at the point of serialization, which would
  #              cause performance to be affected.
  # references:  lib/plugins/instance.rb,
  #              app/models/topic_list.rb,
  #              app/models/concerns/has_custom_fields.rb
  ##
  add_preloaded_topic_list_custom_field(Price)
  add_preloaded_topic_list_custom_field(URL)
  add_preloaded_topic_list_custom_field(Store)
  ##
  # type:        step
  # number:      4.3
  # title:       Serialize to the topic list
  # description: Send your preloaded field to the topic list.
  # references:  lib/plugins/instance.rb,
  #              app/serializers/topic_list_item_serializer.rb
  ##
  add_to_serializer(:topic_list_item, Price.to_sym) do
    object.send(Price)
  end

    add_to_serializer(:topic_list_item, URL.to_sym) do
      object.send(URL)
    end

        add_to_serializer(:topic_list_item, Store.to_sym) do
          object.send(Store)
        end

end
