Workflow to Maintain This Gem
=============================

I use the gem-release gem

For more info see: https://github.com/svenfuchs/gem-release#usage

Steps for an update
-------------------

1. Update code and commit it.
2. Add entry to CHANGELOG and commit it:
   * h1 for major release
   * h2 for minor release
   * h3 for patch release
3. Update version in .gemspec and commit
4. Release it.
   * `gem release`
5. Create a git tag and push to origin.
   `gem tag`


http://prioritized.net/blog/gemify-assets-for-rails/
