$queries_executed = 0

# YouShouldntBeCallingTheDatabaseRecursivelyInYourViews
require 'action_controller/base'
class ActionController::Base
  def render_with_db_protection(*args)
    count_before = $queries_executed
    render_without_db_protection(*args)
    count =  $queries_executed - count_before
    if count > 0
      render_for_text(%|<div style="position:absolute; top:50px; left:50px; width:800px; height: 400px; background-color: white;"><img src="#{matthewrudy_url}" style="float:left"/><blockquote style="font-size:40px;">&laquo;You shouldn't be calling the database recursively in your views&raquo;</blockquote></div>|, nil, true)
    end
  end
  alias_method_chain :render, :db_protection
  
  def matthewrudy_url
    File.exist?(File.join(Rails.root, "public", "matthewrudy.jpg")) ? "/matthewrudy.jpg" : "http://www.gravatar.com/avatar/e60b2dc57668b5662ce3f07781e41710?s=400"
  end
end

# stolen from rails tests, with an integer count rather than an array, and SHOW TABLES and SHOW FIELDS added to the ignore list
ActiveRecord::Base.connection.class.class_eval do
  IGNORED_SQL = [/^PRAGMA/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SHOW TABLES/, /^SHOW FIELDS FROM/, ]

  def execute_with_query_record(sql, name = nil, &block)
    unless self.stop_recording_queries
      $queries_executed +=1 unless IGNORED_SQL.any? { |r| sql =~ r }
    end
    execute_without_query_record(sql, name, &block)
  end

  alias_method_chain :execute, :query_record
  
  attr_accessor :stop_recording_queries
  def without_query_record
    state_before, self.stop_recording_queries = self.stop_recording_queries, true
    return yield
    self.stop_recording_queries = state_before
  end
end

require 'active_support/cache'
class ActiveSupport::Cache::Store
  def fetch_with_query_record_off(*args, &block)
    ActiveRecord::Base.connection.without_query_record do
      return fetch_without_query_record_off(*args, &block)
    end
  end
  alias_method_chain :fetch, :query_record_off
end