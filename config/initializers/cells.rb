ActiveSupport::Notifications.subscribe 'read_fragment.cells' do |_name, _start, _finish, _id, payload|
  Rails.logger.debug "CACHE: #{payload}"
end

ActiveSupport::Notifications.subscribe 'write_fragment.cells' do |_name, _start, _finish, _id, payload|
  Rails.logger.debug "CACHE write: #{payload}"
end
