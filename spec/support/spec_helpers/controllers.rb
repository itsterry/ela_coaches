module SpecHelpers
  module Controllers
    def process_create(params = {})
      process :create, method: :post, params: params, format: :html
    end

    def process_destroy(params = {})
      process :destroy, method: :delete, params: params, format: :html
    end

    def process_edit(params = {})
      process :edit, method: :get, params: params, format: :html
    end

    def process_index(params = {})
      process :index, method: :get, params: params, format: :html
    end

    def process_new(params = {})
      process :new, method: :get, params: params, format: :html
    end

    def process_show(params = {})
      process :show, method: :get, params: params, format: :html
    end

    def process_update(params = {})
      process :update, method: :patch, params: params, format: :html
    end
  end
end
