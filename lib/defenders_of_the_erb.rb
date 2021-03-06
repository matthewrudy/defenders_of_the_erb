$queries_executed = []

# Defenders of the ERb
require 'action_controller/base'
class ActionController::Base
  def render_with_db_protection(*args)
    $queries_executed = []
    render_without_db_protection(*args)
    queries_executed = $queries_executed.dup
    queries_count =  queries_executed.length
    logger.info("defenders of the erb: #{queries_count} uncached queries made!")
    if queries_count > (ENV["QUERY_MAX"] || 5).to_i
      alert_html = <<-HTML
        <div id="matthewrudy-query-box" style="position:absolute; top:50px; left:50px; width:800px; height: 400px; background-color: white; border: 1px solid black">
          <img src="#{matthewrudy_url}" style="float:left"/>
          <blockquote style="font-size:40px;">
            &laquo;You shouldn't be calling the database recursively in your views&raquo;
          </blockquote>
          <blockquote style="font-size:20px;">
            You called the database, uncached, #{queries_count} times, that's way too many. (<a href="#" onclick="document.getElementById('matthewrudy-queries-list').style.display = 'block'; return false;">show</a>)</p>
          </blockquote>
          <a href="#" title="close this matthewrudy" onclick="document.getElementById('matthewrudy-query-box').style.display='none';document.getElementById('matthewrudy-queries-list').style.display='none';return false;">close</a>
        </div>
        <div id="matthewrudy-queries-list" style="position:absolute; top:460px; left:50px; width:800px; background-color: white; border: 1px solid black; display:none; overflow: auto">
          #{queries_executed.map{|query| "<pre><code class='sql'>#{query}</code></pre>"}.join("\n")}
        </div>
      HTML
      render_for_text(alert_html, nil, true)
    end
    #logger.info("MatthewRudy query count: #{queries_count}")
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
      $queries_executed << sql unless IGNORED_SQL.any? { |r| sql =~ r }
    end
    execute_without_query_record(sql, name, &block)
  end
  alias_method_chain :execute, :query_record

  attr_accessor :stop_recording_queries
  def without_query_record
    state_before, self.stop_recording_queries = self.stop_recording_queries, true
    rtn = yield
    self.stop_recording_queries = state_before
    return rtn
  end
end

require 'active_support/cache'
class ActiveSupport::Cache::Store
  def fetch_with_query_record_off(*args, &block)
    ActiveRecord::Base.connection.without_query_record do
      fetch_without_query_record_off(*args, &block)
    end
  end
  alias_method_chain :fetch, :query_record_off
end

require 'action_controller/caching/fragments'
module ActionController::Caching::Fragments
  def fragment_for_with_query_record_off(*args, &block)
    ActiveRecord::Base.connection.without_query_record do
      fragment_for_without_query_record_off(*args, &block)
    end
  end
  alias_method_chain :fragment_for, :query_record_off
end