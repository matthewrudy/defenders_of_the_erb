# Include hook code here
require 'you_shouldnt_be_calling_the_database_recursively_in_your_views' if Rails.env == "development"