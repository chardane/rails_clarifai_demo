# Ruby on Rails Crash Course

This is just to show you a quick demo of things you can do with rails.

First, [install rails on your machine](http://installrails.com/).

### Create a new app
On the command line, run:
```
$ rails new rails_clarifai_demo
```
That will create a bunch of boilerplate code that sets up a base app. In it, you'll have folders for the views, the models, the controllers, tests, etc.

Now, you can actually run the server:
```
$ bundle exec rails server
```
and you'll see your blank canvas - the beginning of your genius app.

### Magic cheat code: Scaffolding

Let's say you wanted to make an app that can keep track of the list of gifts you need to buy your mom for Mother's Day. I'll show you how to create this app in less than 10 seconds with one command.

Exit your `server` with `ctrl+c` and run this command:

```
$ rails generate scaffold Gift item:string quantity:integer bought:boolean
```

That command basically said "Hey Rails, I want the basic code to manipulate a data model called `Gift` with attributes called `item` which is a string, `quantity` which is an integer, and `bought` which is a boolean."

Now, since we created a model, we need to create a database that will hold data, and rails can do this for us with one more command:

```
$ rake db:migrate
```

Then run the your server back up again with `bundle exec rails s` (yeah, that's a shortcut :D)

Now, we can go to [http://localhost:3000](http://localhost:3000) and we can see that we can now view, add, edit and delete gifts!

Did you notice it only took three commands?

### Let's make something cooler.

Ok, making apps that save things for you is great, but let's say we wanted to be _more ambitious_

Let's make an app that can take in an image url, and then return words or `tags` that recognizes the things within that image. Luckily for us, _There's an API for that_<sup>TM</sup>

Stop your server again with `ctrl+c`.

### Create a controller and view

First, we need to create a controller and a view - the controller will hold the logic, and the view will take care of presenting the result of the logic.

```
$ rails generate controller home index --no-helper
```

To keep it simple, i just created a controller called `home`, with one "action" called `index`.

And then, we need to edit the `routes.rb` file. Replace the line `get home/index` with this line:
```ruby
root "home#index"
```
That's special syntax to tell the app to go to the `index` action on the controller whenever a user visits the `root` path of the app, which, in our development local machine, is just `localhost:3000/`

Now, we're going to do a little sidestep here, and discuss a part of a pretty common interview question: What happens when you type a URL into the address bar and press enter? We're only going to talk about this process AFTER the request is received by our Rails application.

1. The app will look at the `routes.rb` file and match the path (in this case, the root path `/`) in the routes file, and the route file knows what controller to route that request to

2. When the controller receives the request, it does whatever it needs to do, such as pulling data from the model, or pulling data from somewhere else, and then rendering the view with that data. The view can then decide how it needs to present the data.

We can run the server again (you know how to do it by now) to see what we got.

### Use a gem

Ok, now for the fun stuff. We can use `gems` in our rails app - these are bits of code that other people have created.

Installing a gem into your app is simple. Since we want to create an app that does visual image recognition, we can use an API that does just that called Clarifai. Conveniently, there is a Ruby client gem that you can use to directly interface with this API.

Add this to your Gemfile (at the very bottom, to keep it simple.)

```ruby
gem 'clarifai_ruby'
```

That's it! This allows us to use the code in the gem [ClarifaiRuby](https://github.com/chardane/ClarifaiRuby) to be able to get tags for a given image URL.

Because we [read the docs for this gem](https://github.com/chardane/ClarifaiRuby), we know that we're going to need to add a client secret and client id to use the gem, so let's add another gem called `dotenv-rails` so that we can read values from a hidden `.env` file.

We know that we need to also add some initial configuration for the gem, so we create a file `initializers/clarifai_ruby.rb` with this:

```ruby
ClarifaiRuby.configure do |config|
  config.base_url       = "https://api.clarifai.com"
  config.version_path   = "/v1"
  config.client_id      = ENV['CLARIFAI_CLIENT_ID']
  config.client_secret  = ENV['CLARIFAI_CLIENT_SECRET']
end
```

Ok, now we can really use the gem! Like I said earlier, we'll need to put the logic in the controller, and then let the view handle the presentation.

### Edit the code!

We edit the controller `home_controller.rb` to look like this:

```ruby
class HomeController < ApplicationController
  def index
    get_tags if params[:image_url].present?
  end

  private

  def get_tags
    # Get tags for the image given from Clarifai
    @tag_response = ClarifaiRuby::TagRequest.new.get(params[:image_url])

    # Extract out just the words from the tags
    @tags = @tag_response.tag_images.first.tags_by_words

    # Save the image url so we can access it later
    @image_url = params[:image_url]
  end
end
```

And we edit the view `home/index.html.erb` to look like this:
```html
<h1>Tag an image</h1>

<%= form_tag "/", method: "get" do %>
  <%= label_tag(:image_url, "Image URL:") %>
  <%= text_field_tag(:image_url) %>
  <%= submit_tag("Tag it!") %>
<% end %>

<br />

<%# Display the image that was given %>
<div class="image_wrapper">
  <%= image_tag @image_url if @image_url %>
</div>

<%# Loop over the list that of words and display them in their own list item %>
<ul class="tags_list">
  <% if @tags %>
    <% @tags.each do |tag| %>
      <li><span><%= tag %></span></li>
    <% end %>
  <% end %>
</ul>
```

And to make this page a bit more usable, we can add some CSS in `home.scss`

```css
.image_wrapper {
  width: 50%;
  display: inline-block;
  text-align: center;
}

.image_wrapper img {
  max-width: 100%;
  margin: auto;
}

.tags_list {
  display: inline-block;
  width: 40%;
  list-style-type: none;
  vertical-align: top;
}

.tags_list li {
  margin: 10px 2px;
  display: inline-block;
}

.tags_list li span {
  background-color: rgba(0,0,0,0.04);
  padding: 5px;
  border-radius: 5px;
}
```

Your finished product should now look like this:

![finished](/app/assets/images/finished.png)

That's it! I hope you enjoyed the tutorial. Go forth and build some cool stuff with Rails!

### Sample images
Here's some sample images for you to try out the app with (note that these images may not exist anymore, but they did at the time of writing.):

Corgi:
```
https://pbs.twimg.com/profile_images/378800000674268962/06ce58cab26c3a0daf80cf57e5acb29b_400x400.jpeg
```
Tulips:
```
http://www.woodenshoe.com/media/field-of-tulips1.jpg
```

UC Davis football field:
```
https://upload.wikimedia.org/wikipedia/commons/8/8a/Aggie_Stadium_(UC_Davis).jpg
```
