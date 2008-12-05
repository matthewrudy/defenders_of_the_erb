class ActionController::Base
  #   def render_for_file(template_path, status = nil, layout = nil, locals = {}) #:nodoc:
  #     logger.info("Rendering #{template_path}" + (status ? " (#{status})" : '')) if logger
  #     render_for_text @template.render(:file => template_path, :locals => locals, :layout => layout), status
  #   end
  # 
  #   def render_for_text(text = nil, status = nil, append_response = false) #:nodoc:
  #     @performed_render = true
  # 
  #     response.headers['Status'] = interpret_status(status || DEFAULT_RENDER_STATUS_CODE)
  # 
  #     if append_response
  #       response.body ||= ''
  #       response.body << text.to_s
  #     else
  #       response.body = case text
  #         when Proc then text
  #         when nil  then " " # Safari doesn't pass the headers of the return if the response is zero length
  #         else           text.to_s
  #       end
  #     end
  #   end
  def render_for_file_with_db_protection(*args)
    #count = ActiveRecord.count_calls do
      render_for_file_without_db_protection(*args)
    #end
    #if count > 5
      render_for_text("<h1>Amazing</h1>", nil, true)
    #end
  end
  alias_method_chain :render_for_file, :db_protection
end