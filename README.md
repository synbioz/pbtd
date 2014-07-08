# Push Button To Deploy

## Repository configuration

The git repository uses the `git flow` scripts. This is the configuration found in `.git/config`:

<pre>
[gitflow "branch"]
  master = release
  develop = master
[gitflow "prefix"]
  feature = feature/
  release = release/
  hotfix = hotfix/
  support = support/
  versiontag =
</pre>

The develop branch is `master` and the production releases branch is `release`. **THIS IS NOT THE DEFAULT BEHAVIOUR OF GIT FLOW.**

## Database

The application uses postgresql as RDMS.

I recommends to create a specific user with limited rights on the database. For instance, I do not allow my users to create or remove databases.
Thus, you should create your development and testing databases manually.

## Test stack

The application uses RSpec as test framework. In development mode, Guard is used as a test triggerer.

The `fabrication` gem provides factories.

To play the test suite run : `bundle exec rspec`

To launch the guard test engine run: `bundle exec guard`
