# YouShouldntBeCallingTheDatabaseRecursivelyInYourViews
require 'action_controller/base'
class ActionController::Base
  def render_with_db_protection(*args)
    #count = ActiveRecord.count_calls do
      render_without_db_protection(*args)
    #end
    #if count > 5
      render_for_text(%|<div style="position:absolute; top:50px; left:50px; width:800px; height: 400px; background-color: white;"><img src="http://www.gravatar.com/avatar/e60b2dc57668b5662ce3f07781e41710?s=400" style="float:left"/><blockquote style="font-size:40px;">&laquo;You shouldn't be calling the database recursively in your views&raquo;</blockquote></div>|, nil, true)
    #end
  end
  alias_method_chain :render, :db_protection
end