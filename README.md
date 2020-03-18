# GemGem on Rails 6

We will build an app that allow Commenting on Things. The app is the same as
https://github.com/apotonick/gemgem-trbrb but on Rails 6 and trb 2.1 (I will
note the differences because of this upgrade).

You should buy and follow the book https://leanpub.com/trailblazer to get a full
picture. Main purpose of this repository is that you can follow the book on
recent Rails version.

In this README we will explain briefly how you can use trb, but more important,
we will link to the method sources in appropriate gems so you can get full
understanding. But again, to learn Trailblazer you should read the book
https://leanpub.com/trailblazer

## Chapter-03 Operations and Forms

After starting new rails app `rails new gemgem-trb-rails-6` we want to implement
CRUD (Create, Read, Update and Delete) for `Thing`. There is nothing wrong in
using rails generators for that
```
rails g model thing name:text description:text
```

Insert route
```
# config/routes.rb
  resources :things
  root 'things#index'
```

and add flash messages to layout just to see some notifications
```
# app/views/layouts/application.html.erb
  <body>
    <%= flash[:notice] %>
    <%= flash[:alert] %>
    <%= yield %>
  </body>
```

and add foundation and enable jQuery (look in `config/webpack/environment.js`)
```
yarn add jquery motion-ui foundation-sites
```

Instead of writing a code in controller or service object, we will start
creating folders inside `app/concepts/` so for our `Thing` model it will be
folder `app/concepts/thing` (trb always use singular). Inside that folder, we
will create folders for each layer we need, for example we need operation create
so we will start with a file `app/concepts/thing/operation/create.rb`. Since
rails autoloader expects name like `Thing::Operation::Create` we are good to go.
Note that in the book it was used without nested `operation` folder
`app/concepts/comment/operation.rb`, but better is to create folder.

```
# app/concepts/operation/create.rb
module Thing::Operation
  class Create < Trailblazer::Operation
  end
end
```
You can also run a test to see if it is properly loaded:
```
require 'test_helper'

class ThingOperationCreateTest < ActiveSupport::TestCase
  test 'persist' do
    result = Thing::Operation::Create.(
      params: {
      },
    )
    assert result.success?
  end
end
```

You can run tests with `rake` and you should see one green dot (success test).

Now we need to fetch data from params what are send to controller. In this case
we will not use `rails generate controller things create` since it will also
create helper and stylesheet but we do not need that. Instead we will manually
write controller and use `run` method from `trailblazer-rails` gem
https://github.com/trailblazer/trailblazer-rails to invoke operation and pass
params.

NOTE that trb is extenting application controller
[here](https://github.com/trailblazer/trailblazer-rails/blob/68694ccafc58d26dcf1d715c67ac1581cb07a7fa/lib/trailblazer/rails/railtie/extend_application_controller.rb#L20)
and `run` method automatically pass `params` to the operation
[here](https://github.com/trailblazer/trailblazer-rails/blob/68694ccafc58d26dcf1d715c67ac1581cb07a7fa/lib/trailblazer/rails/controller.rb#L41).
To pass another parameters like dependencies such as `current_user` you can
override
[_run_options](https://github.com/trailblazer/trailblazer-rails/blob/68694ccafc58d26dcf1d715c67ac1581cb07a7fa/lib/trailblazer/rails/controller.rb#L34)
on the controller like this (note that we do not use this currently)

```
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  def _run_options(options)
    options.merge current_user: current_user
  end
end
```

`run` method will set
[@model](https://github.com/trailblazer/trailblazer-rails/blob/68694ccafc58d26dcf1d715c67ac1581cb07a7fa/lib/trailblazer/rails/controller.rb#L49)
and also the `@form` if it exists (if `step Contract:Build` was called and
contract initialized in `result['contract.default']`, we will explain it below
when we implement contract).
You can also use
[result](https://github.com/trailblazer/trailblazer-rails/blob/68694ccafc58d26dcf1d715c67ac1581cb07a7fa/lib/trailblazer/rails/controller.rb#L59)
method to inspect results. By convention operation should populate
`result[:model]` object (which is array in case of index operation). In trb 2.1
we are using `ctx` name instead of `result` (just remember they are synonyms).

If operation can go wrong (success and error track) than you can use the block
syntax `run Thing::Operation::Create do |result|` so block (success path) will
be called on success and you should `return some_path` at the end so the code
after `run` will not be executed (failure path).

```
# app/controllers/things_cotroller.rb
class ThingsController < ApplicationController
  def new
    run Thing::Operation::Create
  end

  def create
    run Thing::Operation::Create do |result|
      return redirect_to result[:model]
    end

    render action: :new
  end
end
```

To implement validation trb uses gem `reform`
https://github.com/trailblazer/reform and we store our code in `contract`
folder.
```
# app/concepts/thing/contract/create.rb
module Thing::Contract
  class Create < Reform::Form
    property :name
    property :description

    validates :name, presence: true
    validates :description, length: {in: 4..160}, allow_blank: true
  end
end
```

In operation we can use readable short synonyms (macros) which we need to learn:

**Model** http://trailblazer.to/gems/operation/2.0/api.html#model-findby source
is defined in trailblazer-macro gem (not trailblazer-operations)
https://github.com/trailblazer/trailblazer-macro/blob/master/lib/trailblazer/macro/model.rb
```
step Model(Thing, :new) # this is the same as ctx[:model] = Thing.new
step Model(Thing, :find_by) # this is the same as ctx[:model] = Thing.find_by params[:id]
                            # There will be automatic jump to error track if can not find the model
```

**Contract::Build** is defined in trailblazer-macro-contract gem
https://github.com/trailblazer/trailblazer-macro-contract/blob/master/lib/trailblazer/operation/contract.rb#L15
```
step Contract::Build( constant: Thing::Contract::Create )
# this will populate contract.default (and result.contract.default) with
# Reform.new ctx[:model]] like this line
# ctx['contract.default'] = Thing::Contract::Create.new(ctx[:model])
# https://github.com/trailblazer/trailblazer-macro-contract/blob/master/lib/trailblazer/operation/contract.rb#L15

step Contract::Validate( key: :venue )
# https://github.com/trailblazer/trailblazer-macro-contract/blob/master/lib/trailblazer/operation/validate.rb
# this will fetch contract.default and valide against key
# reform_contract = ctx["contract.default"]
# result = reform_contract.validate(ctx["params"][:venue])
# error will be available in result['result.contract.default'].errors.messages
# in reform 2.2.4 in result['contract.default']

step Contract::Persist()
# this will save contract data. Note that it will not change ctx['model']
# reform_contract = ctx["contract.default"]
# reform_contract.save
```

So our operation looks like
```
# app/concepts/operation/create.rb
module Thing::Operation
  class Create < Trailblazer::Operation
    step Model(Thing, :new)
    step Contract::Build(constant: Thing::Contract::Create)
    step Contract::Validate(key: :thing)
    step Contract::Persist()
  end
end
```

Now we can write a test for validations
```
# test/concepts/thing/create_test.rb
require 'test_helper'

class ThingOperationCreateTest < ActiveSupport::TestCase
  # Create
  test 'without params' do
    result = Thing::Operation::Create.(
      params: {
      },
    )
    refute result.success?
    assert result[:model].is_a? Thing
  end

  test 'persist' do
    result = Thing::Operation::Create.(
      params: {
        thing: {
          name: 'MyThing',
        },
      },
    )
    assert result.success?
    assert_equal 'MyThing', result[:model].name
  end

  test 'validation errors' do
    result = Thing::Operation::Create.(
      params: {
        thing: {
          description: 'a',
        },
      },
    )
    refute result.success?
    assert_equal 'can\'t be blank', result['result.contract.default'].errors.messages[:name].first
    assert_equal 'is too short (minimum is 4 characters)', result['result.contract.default'].errors.messages[:description].first
  end
end
```

To create integration test we should have a template. In case of error will
render again the `new` template, and in case of success, we will redirect to new
action.
```
# app/views/thiings/new.html.haml
New thing
= @form.errors if @form.errors.present?
= form_for @form do |f|
  = f.text_field :name
  = f.submit
```

We will not write `test/controllers` since there is no much code in controllers
(also not `test/integration/` since it uses the same `class ThingsControllerTest
< ActionDispatch::IntegrationTest`).
We will use system test and write a test for happy path (and eventual one error
path). System test is performed in real browser using capybara and webdrivers
(gems already included in Rails 6). It is called the wiring/smoke/click test.
```
# test/system/things_test.rb
require 'application_system_test_case'

class ThingsTest < ApplicationSystemTestCase
   test 'allow anonymous' do
     visit new_thing_path
     click_on 'Create Thing'
     assert_selector '#alert', text: 'Error'

     fill_in 'Name', with: 'My Name'
     click_on 'Create Thing'
     assert_selector '#notice', text: 'Successfully created'
   end
end
```

Run system test with
```
# run all tests
bin/rails test:system test

# run specific test
bin/rails test test/system/things_test.rb:10
```

For update action, lets assume than name is not updatable. We can achieve that
by overriding `property :name` in `Update` contract using a
[write-only](http://trailblazer.to/gems/reform/options.html#read-only) option

```
# app/concepts/thing/contract/update.rb
module Thing::Contract
  class Update < Create
    property :name, writeable: false
  end
end
```

Here is a test for that, note that we use `Create` operation as a factory.

```
# test/concepts/thing/update_test.rb
require 'test_helper'

class ThingOperationCreateTest < ActiveSupport::TestCase
  test 'persist valid, ignores name' do
    result = Thing::Operation::Create.(params: { thing: { name: 'Rails', description: 'Kickass web dev' }})
    thing = result[:model]

    Thing::Operation::Update.(
      params: {
        id:    thing.id,
        thing: { name: 'Lotus', description: 'MVC, well..'},
      },
    )

    thing.reload
    assert_equal thing.name, 'Rails'
    assert_equal thing.description, 'MVC, well..'
  end
end
```

In the view, we can use `@form.readonly?(:name)` to check if it a readonly and
disable input field. We will test that field is disabled in system test
```
# test/system/things_test.rb
     thing = Thing.find_by(name: 'My Name')
     visit edit_thing_path(thing)
     assert_selector '#thing_name[readonly="readonly"][value="My Name"]'
     fill_in 'Description', with: 'My Desc'
     click_on 'Update Thing'
     assert_selector '#notice', text: 'Successfully updated'
     assert_match /My Desc/, page.body
```

## Chapter-04 Rails views and Encapsulation

Cells gem https://github.com/trailblazer/cells is like a widget which has input
(like current page in paginated list) so we know that is it's interface.
In view it is used like
```
<%= concept('thing/cell', Thing.last) %>
# which is translated to `Thing::Cell.new(Thing.last).show`.
# but we need parent_controller
```
Cell is an object that contains all methods that are used in view. We can define
`show` method (it is defined by default and it calls `render` so we can skip
it).
```
# app/concepts/thing/cell.rb
class Thing::Cell < Cell::Concept
  def show
    render
  end
end
```
`render` will look for the `app/concepts/thing/views/show.haml`, parse and
return html string.

Different UI formats are handled with different cells.
Inside template every method is a method on cell instance. Inside methods we
have access to `model` and `options`.
Also inside cell you can access Rails view helpers like
`link_to`. Also, you can use properties on model to save typing instead of
`model.name` you can use `name`.
To render collection you can use
```
<%= concept('thing/cell', collection: Thing.all, last: Thing.all) %>
```

To test we will can use system test
```
# test/system/things_test.rb
require 'application_system_test_case'

class ThingsTest < ApplicationSystemTestCase
  test 'cell' do
    Thing::Operation::Create.(params: { thing: { name: 'My Name' }})
    Thing::Operation::Create.(params: { thing: { name: 'Your Name' }})
    visit things_path
    assert_selector '.columns', text: 'My Name'
    assert_selector '.columns.end', text: 'Your Name'
  end
end
```
or `Cell::TestCase` which on Rails 6.0.2 needs to use
::ActionDispatch::TestRequest.create
https://github.com/trailblazer/cells-rails/issues/57
TODO: Add integration test
```

```

TODO: Switch to new gem version
Instead of `Cell::Concept` (cells version 4.1.7) now (cells version 5) we should
use `Trailblazer::Cell` http://trailblazer.to/gems/cells/trailblazer.html
(folder is `view` instead of `views`, class is inside subfolder, for example
`cell/show.rb` so the name would be `Thing::Cell::Show`).

