# Automates the steps for creating an empty Ruby on Rails application and deploying it to Github,
# based on https://devcenter.heroku.com/articles/getting-started-with-ruby#set-up.
# Assumes the User has installed and enabled postgresql on their machine.

# Takes several command line parameters:
# 	- The name of the app
#	- The postgresql database username
#	- The postgresql database password
#	- Your Github username
RUBY_VERSION=( $( ruby -v ) )
RUBY_VERSION=${RUBY_VERSION[1]}
ar=(${RUBY_VERSION//p/ })
RUBY_VERSION=${ar[0]}

if [ "$#" -lt 4 ]; then
  echo "ERROR: Please enter 4 command line parameters:"
  echo "- The name of the app"
  echo "- The postgresql database username"
  echo "- The postgresql database password"
  echo "- Your Github username"
  exit 1
fi
echo "Creating new Rails app "$1
rails new $1 --database=postgresql
cd $1/
rails g controller welcome
sed "s/# root 'welcome#index'/root 'welcome#index'/g" config/routes.rb > config/routes2.rb
mv config/routes2.rb config/routes.rb
printf "$( cat Gemfile )\n\ngem 'rails_12factor', group: :production\n\nruby \"$RUBY_VERSION\"\n" > Gemfile
bundle install
sed "s/username: $1/username: $2/g" config/database.yml > config/database2.yml
sed "s/password:/password: $3/g" config/database2.yml > config/database.yml
rm config/database2.yml

bundle exec rake db:create

git init
git add .
git commit -m "Initialized empty Rails application"
git remote add origin git@github.com:/$4/$1.git
git push -u origin master
