# YouShouldntBeCallingTheDatabaseRecursivelyInYourViews
require 'action_controller/base'
class ActionController::Base
  def render_with_db_protection(*args)
    #count = ActiveRecord.count_calls do
      render_without_db_protection(*args)
    #end
    #if count > 5
      render_for_text(%|<h1>Amazing</h1><img src="http://www.gravatar.com/avatar/e60b2dc57668b5662ce3f07781e41710?s=400" style="position:absolute; top:50px; left:50px;"/>|, nil, true)
    #end
  end
  alias_method_chain :render, :db_protection
end