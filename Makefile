ruby:
	ruby victoria.rb
crystal-dev:
	crystal victoria.cr --error-trace
crystal-release:
	crystal build --progress --release --no-debug victoria.cr && ./victoria
