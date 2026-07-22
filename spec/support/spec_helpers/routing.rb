def route_check(url, controller, action, options = {}, verb = 'get')
  describe url, type: :routing do
    it 'should route correctly' do
      expected = {
        controller: controller,
        action: action
      }.merge options
      expect(verb => url).to route_to expected
    end
  end
end

# Checks every RESTful route for a resource. `path` is the URL prefix,
# `controller` the controller key, `options` any nested params (e.g. availability_id),
# `actions` which of the 7 RESTful actions the resource exposes, and
# `member_param` the member key (defaults to :id).
def route_check_resource(path, controller, options = {}, actions = %i[index new create show edit update destroy], member_param = :id)
  member = options.merge(member_param => '1')

  route_check(path, controller, 'index', options) if actions.include?(:index)
  route_check("#{path}/new", controller, 'new', options) if actions.include?(:new)
  route_check(path, controller, 'create', options, 'post') if actions.include?(:create)
  route_check("#{path}/1", controller, 'show', member) if actions.include?(:show)
  route_check("#{path}/1/edit", controller, 'edit', member) if actions.include?(:edit)
  route_check("#{path}/1", controller, 'update', member, 'patch') if actions.include?(:update)
  route_check("#{path}/1", controller, 'destroy', member, 'delete') if actions.include?(:destroy)
end
